//
//  Activity.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/23/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct ActivityItem: Identifiable {
    let id = UUID()
    let bookingKey: String
    let message: String
    let dateString: String
}

class ActivityViewModel: ObservableObject {
    @Published var activities = [ActivityItem]()
    private let ref = Database.database().reference()

    func fetchActivities() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let bookingsRef = ref.child("bookings")
        let usersRef = ref.child("users")

        bookingsRef.observe(.value) { [weak self] snapshot in
            var newActivities = [ActivityItem]()
            let group = DispatchGroup()

            for child in snapshot.children {
                guard let self = self,
                      let snapshot = child as? DataSnapshot,
                      let dict = snapshot.value as? [String: Any],
                      let providerUserID = dict["providerUserID"] as? String,
                      providerUserID == currentUserID,
                      let bookerUserID = dict["bookerUserID"] as? String,
                      let rideID = dict["rideID"] as? String,
                      let type = dict["type"] as? String else {
                    continue
                }

                let bookingKey = snapshot.key

                group.enter()
                usersRef.child(bookerUserID).observeSingleEvent(of: .value) { (userSnapshot, _) in
                    var userName = "Unknown User"
                    var userNumber = "Unknown Number"

                    if let userDict = userSnapshot.value as? [String: Any] {
                        userName = userDict["name"] as? String ?? userName
                        userNumber = userDict["number"] as? String ?? userNumber
                    }

                    let rideNode = type == "reservation" ? "rideReserve" : "rideRequest"
                    self.ref.child(rideNode).child(rideID).observeSingleEvent(of: .value) { (rideSnapshot, _) in
                        if let rideDict = rideSnapshot.value as? [String: Any],
                           let dateTimeString = rideDict["date"] as? String {
                            let formattedDateTime = self.formatDateTime(dateTimeString: dateTimeString)
                            var message = ""

                            if type == "reservation" {
                                message = "\(userName) (\(userNumber)) booked a ride from you."
                            } else if type == "request" {
                                message = "\(userName) (\(userNumber)) fulfilled your ride request."
                            } else if type == "cancellation" {
                                message = "\(userName) (\(userNumber)) cancelled a ride."
                            }

                            let activity = ActivityItem(bookingKey: bookingKey, message: message, dateString: formattedDateTime)
                            newActivities.append(activity)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                if let strongSelf = self {
                    strongSelf.activities = newActivities.filter { !strongSelf.isDatePassed(dateString: $0.dateString) }
                }
            }
        }
    }

    private func fetchRideDetails(rideID: String, completion: @escaping (String, String) -> Void) {
        let rideReserveRef = Database.database().reference().child("rideReserve").child(rideID)
        let rideRequestRef = Database.database().reference().child("rideRequest").child(rideID)

        rideReserveRef.observeSingleEvent(of: .value) { snapshot in
            if let rideDict = snapshot.value as? [String: Any],
               let date = rideDict["date"] as? String,
               let time = rideDict["time"] as? String {
                completion(date, time)
            } else {
                rideRequestRef.observeSingleEvent(of: .value) { snapshot in
                    if let rideDict = snapshot.value as? [String: Any],
                       let date = rideDict["date"] as? String,
                       let time = rideDict["time"] as? String {
                        completion(date, time)
                    } else {
                        completion("Date not found", "Time not found")
                    }
                }
            }
        }
    }
    
    private func formatDateTime(dateTimeString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long // Example: November 25, 2023
        dateFormatter.timeStyle = .short // Example: 3:00 AM
        dateFormatter.timeZone = TimeZone.current // Convert to local time zone

        var formattedDateTime = "Unknown Date and Time"

        if let date = isoFormatter.date(from: dateTimeString) {
            formattedDateTime = dateFormatter.string(from: date)
        }

        return formattedDateTime
    }

    private func isDatePassed(dateString: String) -> Bool {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC

        if let date = isoFormatter.date(from: dateString),
           date.addingTimeInterval(86400) < Date() { // 86400 seconds = 1 day
            return true
        }
        return false
    }
    func deleteActivity(at offsets: IndexSet) {
        for index in offsets {
            let activity = activities[index]
            ref.child("bookings").child(activity.bookingKey).removeValue()
        }
        activities.remove(atOffsets: offsets)
    }
}


struct Activity: View {
    @StateObject private var viewModel = ActivityViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.activities.isEmpty {
                    Text("Nothing to see here")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.activities) { activity in
                            HStack(spacing: 15) {
                                Image("logo1png") // Replace with your asset
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                                    .padding(.leading, 5)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(activity.message)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)

                                    Text(activity.dateString)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer() // Add Spacer to push content to the left edge
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                        }
                        .onDelete(perform: viewModel.deleteActivity)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Activity Feed")
            .onAppear {
                viewModel.fetchActivities()
            }
        }
    }
}

struct Activity_Previews: PreviewProvider {
    static var previews: some View {
        Activity()
    }
}
