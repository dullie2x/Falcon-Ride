//
//  RequestsView.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 12/2/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct RequestsCell: View {
    var request: Ride2
    var onDelete: (Ride2) -> Void
    var width: CGFloat
    var height: CGFloat
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                VStack(alignment: .leading) {
                    Text("\(request.fromLocation) to \(request.toLocation)")
                        .font(.title)
                        .foregroundColor(.darkBlue)
                    Text("Date: \(request.date) at \(request.time)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
                .background(Color.gray)
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Text("Donation: \(request.donationRequested)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Text("Seats: \(request.seats)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Text("Additional Info: \(request.additionalInfo ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding([.top, .horizontal])
        .frame(width: width, height: height)
        .overlay(
            VStack {
                if request.userID == Auth.auth().currentUser?.uid {
                    HStack {
                        Spacer()
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        NavigationLink(destination: EditRequest(ride2: Binding.constant(request), rideType: .request), isActive: $isEditing) { EmptyView() }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                }
            }
                .padding(),
            alignment: .topTrailing
        )
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this ride?"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete(request)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct RequestsView: View {
    @State private var userRequests = [Ride2]()
    @State private var isLoading = true
    let segmentedViewWidth = UIScreen.main.bounds.width // Use segmentedViewWidth for consistency
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if isLoading {
                    Text("Loading posted requests...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if userRequests.isEmpty {
                    Text("Nothing here, but mitches anyone?")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(userRequests) { request in
                        RequestsCell(request: request, onDelete: { selectedRide in
                            guard selectedRide.userID == Auth.auth().currentUser?.uid else { return }
                            DataHandler.shared.deleteRide(rideId: selectedRide.id, node: "rideRequest") { error in
                                if error == nil {
                                    userRequests.removeAll(where: { $0.id == selectedRide.id })
                                }
                            }
                        },
                        width: segmentedViewWidth,
                        height: 200
                        )
                        .padding(.horizontal, 15)
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    }
                    .frame(width: segmentedViewWidth) // Set the cell to full screen width
                    .padding(.horizontal, 15)
                }
            }
        }
        .onAppear(perform: fetchUserRequests)
    }
    
    
    private func fetchUserRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }
        
        let ref = Database.database().reference().child("rideRequest")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                isLoading = false
                return
            }
            
            var newUserRequests: [Ride2] = []
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                guard let requestDict = child.value as? [String: Any],
                      let userID = requestDict["userID"] as? String,
                      userID == currentUserID,
                      let fromLocation = requestDict["fromLocation"] as? String,
                      let toLocation = requestDict["toLocation"] as? String,
                      let seats = requestDict["seats"] as? String,
                      let dateString = requestDict["date"] as? String,
                      let timeString = requestDict["time"] as? String,
                      let donationRequested = requestDict["donationRequested"] as? String,
                      let additionalInfo = requestDict["additionalInfo"] as? String else {
                    continue
                }
                
                let formattedDate = formatDate(dateString: dateString)
                let formattedTime = formatTime(timeString: timeString)
                
                let request = Ride2(id: id, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: donationRequested, additionalInfo: additionalInfo)
                newUserRequests.append(request)
            }
            
            userRequests = newUserRequests
            isLoading = false
        }
    }
    
    
    func formatDate(dateString: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        } else {
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            if let fallbackDate = fallbackFormatter.date(from: dateString) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = TimeZone.current
                return dateFormatter.string(from: fallbackDate)
            }
        }
        return dateString
    }
    
    func formatTime(timeString: String) -> String {
        return timeString
    }
}

struct RequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestsView()
    }
}
