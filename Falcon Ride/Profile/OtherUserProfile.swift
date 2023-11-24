//
//  NotMyProfile.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct OtherUserProfile: View {
    var rideInfo: RideInfo // Using RideInfo enum
    @StateObject private var viewModel = OtherUserProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.darkBlue))
                        .scaleEffect(1.5)
                } else {
                    OtherProfileHeaderView(name: viewModel.userName, username: viewModel.userUsername, number: viewModel.userNumber, width: 400, height: 200)
                        .shadow(radius: 10)
                        .padding()
                }
                
                Stepper("Number of Seats: \(viewModel.numberOfSeatsToBook)", value: $viewModel.numberOfSeatsToBook, in: 1...10)
                    .padding(50)
                
                if viewModel.showError {
                    Text(viewModel.alertMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {
                    viewModel.confirmBooking(rideInfo: rideInfo)
                }) {
                    Text("Confirm Booking")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: 200, minHeight: 50)
                        .background(Color.darkBlue)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                .shadow(radius: 5)
                .disabled(viewModel.isLoading)
            }
            .padding()
            .background(Color.white)
            .onAppear { viewModel.fetchOtherUserData(rideInfo: rideInfo) }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text(viewModel.alertMessage))
            }
        }
        .alert(isPresented: $viewModel.shouldPromptForMessage) {
            Alert(
                title: Text("Ride Booked Successfully"),
                message: Text("Would you like to message the driver now?"),
                primaryButton: .default(Text("Yes"), action: {
                    if let url = viewModel.messageDriverURL(phoneNumber: viewModel.userNumber, message: "Hello, I've just booked a ride with you/accepted a request from you!") {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct OtherProfileHeaderView: View {
    var name: String
    var username: String
    var number: String
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(name)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.darkBlue)
            
            Text("@\(username)")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(Color.darkBlue)
            
            Text(number)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(Color.black)
            
            Divider().background(Color.darkBlue)
        }
        .padding()
        .frame(width: width, height: height)
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

class OtherUserProfileViewModel: ObservableObject {
    @Published var numberOfSeatsToBook = 1
    @Published var userName = "Loading..."
    @Published var userUsername = "Loading..."
    @Published var userNumber = "Loading..."
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var shouldPromptForMessage = false
    
    func messageDriverURL(phoneNumber: String, message: String) -> URL? {
        let formattedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        let formattedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return URL(string: "sms:\(formattedNumber)&body=\(formattedMessage ?? "")")
    }
    
    func fetchOtherUserData(rideInfo: RideInfo) {
        isLoading = true
        let userID: String
        switch rideInfo {
        case .reserve(let ride):
            userID = ride.userID
        case .request(let ride2):
            userID = ride2.userID
        }
        
        let userRef = Database.database().reference().child("users").child(userID)
        userRef.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self = self else { return }
            guard let value = snapshot.value as? [String: AnyObject] else {
                self.alertMessage = "No user data found"
                self.showError = true
                self.isLoading = false
                return
            }
            DispatchQueue.main.async {
                self.userName = value["name"] as? String ?? "Unknown"
                self.userUsername = value["username"] as? String ?? "Unknown"
                self.userNumber = value["number"] as? String ?? "Unknown"
                self.isLoading = false
                
            }
        }) { [weak self] error in
            self?.isLoading = false
            self?.alertMessage = "Error fetching user data: \(error.localizedDescription)"
            self?.showingAlert = true
        }
    }
    
    func confirmBooking(rideInfo: RideInfo) {
        guard numberOfSeatsToBook > 0 else {
            alertMessage = "Please enter a valid number of seats."
            showingAlert = true
            return
        }
        bookSeats(numberOfSeats: numberOfSeatsToBook, rideInfo: rideInfo)
    }
    
    
    func bookSeats(numberOfSeats: Int, rideInfo: RideInfo) {
        isLoading = true
        let (rideId, firebaseNode) = getRideDetails(rideInfo: rideInfo)
        let rideRef = Database.database().reference().child(firebaseNode).child(rideId)
        
        rideRef.runTransactionBlock({ [weak self] (currentData: MutableData) -> TransactionResult in
            guard let self = self else { return .abort() }
            if var rideData = currentData.value as? [String: AnyObject], let availableSeats = Int(rideData["seats"] as? String ?? "0") {
                if numberOfSeats <= availableSeats {
                    rideData["seats"] = String(availableSeats - numberOfSeats) as AnyObject
                    currentData.value = rideData
                    return .success(withValue: currentData)
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = "Not enough seats available."
                        self.showingAlert = true
                        self.isLoading = false
                    }
                    return .abort()
                }
            }
            return .abort()
        }, andCompletionBlock: { [weak self] error, committed, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showingAlert = true
                } else if committed {
                    // Trigger the message prompt only after successful booking
                    self.shouldPromptForMessage = true
                }
                self.isLoading = false
            }
        })
    }
    
    private func getRideDetails(rideInfo: RideInfo) -> (rideId: String, firebaseNode: String) {
        switch rideInfo {
        case .reserve(let ride):
            return (ride.id, "rideReserve")
        case .request(let ride2):
            return (ride2.id, "rideRequest")
        }
    }
}
