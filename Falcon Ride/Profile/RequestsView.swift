//
//  RequestsView.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 12/2/23.
//

// RequestsView.swift
import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct Ride5: Identifiable {
    var id: String
    var userID: String
    var fromLocation: String
    var toLocation: String
    var seats: String
    var date: String
    var time: String
    var donationRequested: String
    var additionalInfo: String?
}

struct RequestsCell: View {
    var request: Ride5

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
    }
}

struct RequestsView: View {
    @State private var userRequests = [Ride5]()
    @State private var isLoading = true

    private func fetchUserRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            self.isLoading = false
            return
        }

        let ref = Database.database().reference().child("rideRequest")

        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                self.isLoading = false
                return
            }

            var newUserRequests: [Ride5] = []

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                guard let requestDict = child.value as? [String: Any],
                      let userID = requestDict["userID"] as? String,
                      userID == currentUserID, // Filter only the requests of the logged-in user
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

                let request = Ride5(id: id, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: donationRequested, additionalInfo: additionalInfo)
                newUserRequests.append(request)
            }

            self.userRequests = newUserRequests
            self.isLoading = false
        }
    }

    // Add this function to format the date
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

    // Add this function to format the time
    func formatTime(timeString: String) -> String {
        return timeString
    }

    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    Text("Loading user requests...")
                } else if userRequests.isEmpty {
                    Text("No user requests available.")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(userRequests) { request in
                        RequestsCell(request: request)
                            .padding(.horizontal, 15)
                            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    }
                }
            }
        }
        .onAppear(perform: fetchUserRequests)
    }
}

struct RequestsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestsView()
    }
}
