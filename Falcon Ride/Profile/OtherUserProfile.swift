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
    var rideInfo: RideInfo
    var additionalInfo: String
    var fromLocation: String
    var toLocation: String
    var time: String
    var seats: String
    var donationRequested: String
    @StateObject private var viewModel = OtherUserProfileViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    profileHeaderView
                        .frame(width: geometry.size.width, height: geometry.size.width * 0.5)
                    
                    rideInfoSection
                    
                    Spacer(minLength: 10)
                    
                    seatsStepper
                    
                    errorView
                    
                    Spacer(minLength: 10) // Push content to the center vertically
                    
                    confirmBookingButton
                }
            }
        }
        .padding()
        .background(Color.white)
        .onAppear { viewModel.fetchOtherUserData(rideInfo: rideInfo) }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text(viewModel.alertMessage))
        }
        .alert(isPresented: $viewModel.shouldPromptForMessage) {
            Alert(
                title: Text("Ride Booked/Requested Successfully"),
                message: Text("Would you like to message the user now?"),
                primaryButton: .default(Text("Yes"), action: {
                    if let url = viewModel.messageDriverURL(phoneNumber: viewModel.userNumber, message: "Hello, My name is _____. I've just booked a ride with you/accepted a request from you!") {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    var profileHeaderView: some View {
        if viewModel.isLoading {
            return AnyView(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.darkBlue))
                    .scaleEffect(2.5)
            )
        } else {
            return AnyView(
                OtherProfileHeaderView(name: viewModel.userName, username: viewModel.userUsername, number: viewModel.userNumber)
                    .shadow(radius: 10)
                    .padding()
            )
        }
    }
    
    var rideInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RideInfoCell(
                additionalInfo: additionalInfo,
                fromLocation: fromLocation,
                toLocation: toLocation,
                time: time,
                seats: seats,
                donationRequested: donationRequested
            )
        }
        .padding(.horizontal)
    }
    
    var seatsStepper: some View {
        Stepper("Number of Seats: \(viewModel.numberOfSeatsToBook)", value: $viewModel.numberOfSeatsToBook, in: 1...10)
            .padding(.horizontal)
    }
    
    var errorView: some View {
        if viewModel.showError {
            return AnyView(
                Text(viewModel.alertMessage)
                    .foregroundColor(.red)
                    .padding()
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var confirmBookingButton: some View {
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
}


struct OtherProfileHeaderView: View {
    var name: String
    var username: String
    var number: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("@\(username)")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(Color.darkBlue)
        }
        .padding()
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
        
        // Determine booking type and record the booking
        let bookingType = getBookingType(rideInfo: rideInfo)
        let bookerUserID = Auth.auth().currentUser?.uid ?? ""
        let (rideId, _) = getRideDetails(rideInfo: rideInfo)
        
        // Assuming that the provider's userID is already stored in rideInfo
        let providerUserID = getProviderUserID(rideInfo: rideInfo)
        
        DataHandler.shared.recordBooking(rideID: rideId, bookerUserID: bookerUserID, providerUserID: providerUserID, type: bookingType) { error in
            if let error = error {
                print("Error recording booking: \(error.localizedDescription)")
            }
        }
    }
    private func getBookingType(rideInfo: RideInfo) -> String {
        switch rideInfo {
        case .reserve(_):
            return "reservation"
        case .request(_):
            return "request"
        }
    }
    
    // Helper method to get the provider's userID from rideInfo
    private func getProviderUserID(rideInfo: RideInfo) -> String {
        switch rideInfo {
        case .reserve(let ride):
            return ride.userID
        case .request(let ride2):
            return ride2.userID
        }
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
                        self.showError = true // Set showError to true to display the error message
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
                    self.showError = true // Set showError to true to display the error message
                } else if committed {
                    self.alertMessage = "Seats booked successfully."
                    self.shouldPromptForMessage = true // Trigger the message prompt only after successful booking
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

struct RideInfoCell: View {
    var additionalInfo: String
    var fromLocation: String
    var toLocation: String
    var time: String
    var seats: String
    var donationRequested: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional Info")
                    .font(.headline)
                    .foregroundColor(.darkBlue)
                Text("\"\(additionalInfo)\"")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("From:")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    Text(fromLocation)
                        .font(.subheadline)
                }
                
                HStack {
                    Text("To:")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    Text(toLocation)
                        .font(.subheadline)
                }
                
                HStack {
                    Text("Time:")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    Text(time)
                        .font(.subheadline)
                }
                
                HStack {
                    Text("Seats:")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    Text(seats)
                        .font(.subheadline)
                }
                
                HStack {
                    Text("Donation:")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                    Text(donationRequested)
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}



