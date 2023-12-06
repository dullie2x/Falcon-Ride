import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct Ride3: Identifiable {
    var id: String
    var userID: String
    var fromLocation: String
    var toLocation: String
    var seats: String
    var date: String
    var time: String
    var donationRequested: String
    var userEmail: String?
    var userName: String?
    var userUsername: String?
    var userNumber: String?
    var additionalInfo: String?
}

struct Reservation: Identifiable {
    var id: String
    var ride3: Ride3
    var bookerUserID: String
}

struct ReservationsView: View {
    @State private var reservations = [Reservation]()
    @State private var acceptedRequests = [Reservation]()
    @State private var isLoading = true
    
    
    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    Text("Loading reservations & Accepted Requests...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if reservations.isEmpty && acceptedRequests.isEmpty {
                    Text("Surprise? Nothing here!")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(reservations) { reservation in
                        ReservationCell(reservation: reservation, type: "Booked Ride")
                            .padding(.horizontal, 15)
                            .foregroundColor(.green)
                    }
                    ForEach(acceptedRequests) { request in
                        ReservationCell(reservation: request, type: "Accepted Request")
                            .padding(.horizontal, 15)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            fetchReservations()
            fetchAcceptedRequests()
        }
    }
    
    private func fetchReservations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }
        
        let ref = Database.database().reference()
        let bookingsRef = ref.child("bookings").queryOrdered(byChild: "bookerUserID").queryEqual(toValue: currentUserID)
        
        bookingsRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() == false {
                print("No bookings found for user")
                self.isLoading = false
                return
            }
            
            var newReservations: [Reservation] = []
            let group = DispatchGroup()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let dict = child.value as? [String: Any],
                      let rideID = dict["rideID"] as? String,
                      let type = dict["type"] as? String, type == "reservation" else {
                    continue
                }
                
                group.enter()
                ref.child("rideReserve").child(rideID).observeSingleEvent(of: .value) { (rideSnapshot, errorStringOrNil) in
                    if let errorString = errorStringOrNil {
                        print("Error fetching ride: \(errorString)")
                        group.leave()
                        return
                    }
                    
                    guard let rideDict = rideSnapshot.value as? [String: Any],
                          let userID = rideDict["userID"] as? String,
                          let fromLocation = rideDict["fromLocation"] as? String,
                          let toLocation = rideDict["toLocation"] as? String,
                          let seats = rideDict["seats"] as? String,
                          let dateString = rideDict["date"] as? String,
                          let timeString = rideDict["time"] as? String else {
                        print("Error parsing ride data")
                        group.leave()
                        return
                    }
                    
                    let formattedDate = self.formatDate(dateString: dateString)
                    let formattedTime = self.formatTime(timeString: timeString)
                    
                    ref.child("users").child(userID).observeSingleEvent(of: .value) { (userSnapshot, errorOrNil) in
                        if let error = errorOrNil {
                            print("Error fetching user data: \(error)")
                            group.leave()
                            return
                        }
                        
                        guard let userDict = userSnapshot.value as? [String: Any],
                              let userName = userDict["name"] as? String,
                              let userNumber = userDict["number"] as? String else {
                            group.leave()
                            return
                        }
                        
                        let ride = Ride3(id: rideID, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: "", userEmail: "", userName: userName, userUsername: "", userNumber: userNumber, additionalInfo: "")
                        let reservation = Reservation(id: child.key, ride3: ride, bookerUserID: currentUserID)
                        newReservations.append(reservation)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                self.reservations = newReservations
                self.isLoading = false
            }
        }
    }
    
    
    private func fetchAcceptedRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }
        
        let ref = Database.database().reference()
        let requestsRef = ref.child("bookings").queryOrdered(byChild: "bookerUserID").queryEqual(toValue: currentUserID)
        
        requestsRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() == false {
                print("No accepted requests found for user")
                self.isLoading = false
                return
            }
            
            var newAcceptedRequests: [Reservation] = []
            let group = DispatchGroup()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let dict = child.value as? [String: Any],
                      let rideID = dict["rideID"] as? String,
                      let type = dict["type"] as? String, type == "request" else {
                    continue
                }
                
                group.enter()
                ref.child("rideRequest").child(rideID).observeSingleEvent(of: .value) { (rideSnapshot, errorOrNil) in
                    if let error = errorOrNil {
                        print("Error fetching ride: \(error)")
                        group.leave()
                        return
                    }
                    
                    guard let rideDict = rideSnapshot.value as? [String: Any],
                          let userID = rideDict["userID"] as? String,
                          let fromLocation = rideDict["fromLocation"] as? String,
                          let toLocation = rideDict["toLocation"] as? String,
                          let seats = rideDict["seats"] as? String,
                          let dateString = rideDict["date"] as? String,
                          let timeString = rideDict["time"] as? String else {
                        print("Error parsing ride data")
                        group.leave()
                        return
                    }
                    
                    let formattedDate = self.formatDate(dateString: dateString)
                    let formattedTime = self.formatTime(timeString: timeString)
                    
                    ref.child("users").child(userID).observeSingleEvent(of: .value) { (userSnapshot, errorOrNil) in
                        if let error = errorOrNil {
                            print("Error fetching user data: \(error)")
                            group.leave()
                            return
                        }
                        
                        guard let userDict = userSnapshot.value as? [String: Any],
                              let userName = userDict["name"] as? String,
                              let userNumber = userDict["number"] as? String else {
                            group.leave()
                            return
                        }
                        
                        let ride = Ride3(id: rideID, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: "", userEmail: "", userName: userName, userUsername: "", userNumber: userNumber, additionalInfo: "")
                        let reservation = Reservation(id: child.key, ride3: ride, bookerUserID: currentUserID)
                        newAcceptedRequests.append(reservation)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main) {
                print("Completed fetching \(newAcceptedRequests.count) accepted requests")
                self.acceptedRequests = newAcceptedRequests
                self.isLoading = false
            }
        }
    }
    func formatDate(dateString: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeZone = TimeZone.current // Convert to local time zone
            return dateFormatter.string(from: date)
        } else {
            // Fallback for different date format or non-standard format
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // Adjust this format as needed
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
            
            if let fallbackDate = fallbackFormatter.date(from: dateString) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = TimeZone.current // Convert to local time zone
                return dateFormatter.string(from: fallbackDate)
            }
        }
        return dateString // Return original string if parsing fails
    }
    
    func formatTime(timeString: String) -> String {
        // Implement time formatting logic similar to date formatting
        // Adjust based on your time format in the database
        return timeString
    }
}
    

struct ReservationCell: View {
    var reservation: Reservation
    var type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(type)
                .font(.headline)
                .padding(.bottom, 5)

            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                VStack(alignment: .leading) {
                    Text("\(reservation.ride3.fromLocation) to \(reservation.ride3.toLocation)")
                        .font(.title3)
                        .foregroundColor(.primary)
                    Text("Date: \(reservation.ride3.date) at \(reservation.ride3.time)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Divider().background(Color.gray)

            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                Text("User: \(reservation.ride3.userName ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                if let userNumber = reservation.ride3.userNumber {
                    Link("Contact: \(userNumber)", destination: URL(string: "sms:\(userNumber)")!)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Contact: Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding([.top, .horizontal])
    }
}

struct ReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationsView()
    }
}
