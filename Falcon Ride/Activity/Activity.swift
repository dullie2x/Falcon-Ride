//
//  Activity.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/23/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

// Model for each activity item
struct ActivityItem: Identifiable {
    let id = UUID()
    let message: String
    let dateString: String
}

// ViewModel to handle data fetching and processing
class ActivityViewModel: ObservableObject {
    @Published var activities = [ActivityItem]()

    func fetchActivities() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        let ref = Database.database().reference()
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

                group.enter()
                usersRef.child(bookerUserID).observeSingleEvent(of: .value) { userSnapshot in
                    var userName = "Unknown User"
                    var userNumber = "Unknown Number"

                    if let userDict = userSnapshot.value as? [String: Any] {
                        userName = userDict["name"] as? String ?? userName
                        userNumber = userDict["number"] as? String ?? userNumber
                    }

                    let rideNode = type == "reservation" ? "rideReserve" : "rideRequest"
                    ref.child(rideNode).child(rideID).observeSingleEvent(of: .value) { rideSnapshot in
                        var date = "Unknown Date"
                        var time = "Unknown Time"
                        if let rideDict = rideSnapshot.value as? [String: Any] {
                            date = rideDict["date"] as? String ?? date
                            time = rideDict["time"] as? String ?? time
                        }

                        let formattedDateTime = self.formatDateTime(dateString: date, timeString: time)
                        let message = "\(userName) (\(userNumber)) \(type == "reservation" ? "booked a ride from you." : "fulfilled your ride request.")"

                        let activity = ActivityItem(message: message, dateString: formattedDateTime)
                        newActivities.append(activity)
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self?.activities = newActivities
            }
        }
    }

    private func formatDateTime(dateString: String, timeString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long // Example: November 25, 2023
        dateFormatter.timeStyle = .short // Example: 3:00 AM

        var formattedDateTime = "Unknown Date and Time"

        if let date = isoFormatter.date(from: dateString) {
            formattedDateTime = dateFormatter.string(from: date)
        }
        
        return formattedDateTime
    }

}
    // SwiftUI View for displaying activities
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
                    List(viewModel.activities) { activity in
                        HStack(spacing: 15) {
                            Image("logo1png")
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
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
