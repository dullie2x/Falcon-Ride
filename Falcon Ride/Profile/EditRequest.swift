//
//  EditRequest.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/27/23.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct EditRequest: View {
    @Binding var ride2: Ride2
    var rideType: RideType
    
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var seats: String = ""
    @State private var selectedDate: Date = Date()
    @State private var donationRequested: String = ""
    @State private var additionalInfo: String = ""
    @State private var posting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    init(ride2: Binding<Ride2>, rideType: RideType) {
        self._ride2 = ride2
        self.rideType = rideType
        self._fromLocation = State(initialValue: ride2.fromLocation.wrappedValue)
        self._toLocation = State(initialValue: ride2.toLocation.wrappedValue)
        self._seats = State(initialValue: ride2.seats.wrappedValue)
        self._donationRequested = State(initialValue: ride2.donationRequested.wrappedValue)
        self._additionalInfo = State(initialValue: ride2.additionalInfo.wrappedValue ?? "")
        
        // If the date in the ride is in ISO8601 format, convert it to Date
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: ride2.date.wrappedValue) {
            self._selectedDate = State(initialValue: date)
        } else {
            // Handle the case where the date string is not in the expected format
            self._selectedDate = State(initialValue: Date())
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ride Details")) {
                    TextField("From", text: $fromLocation)
                    TextField("To", text: $toLocation)
                    TextField("Seats", text: $seats)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Select Date and Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Additional Info")) {
                    TextField("Donation Requested", text: $donationRequested)
                    TextField("Other Details", text: $additionalInfo)
                }
                
                Button(action: updateRide) {
                    Text(posting ? "Updating..." : "Update Ride")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(fromLocation.isEmpty || toLocation.isEmpty || seats.isEmpty || donationRequested.isEmpty || posting)
            }
            .navigationBarTitle("Edit Ride", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func updateRide() {
        posting = true
        
        // Format the date in UTC for Firebase
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = isoDateFormatter.string(from: selectedDate)
        
        // Format the time in the user's local time zone
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        let formattedTime = timeFormatter.string(from: selectedDate)
        
        let rideDict: [String: Any] = [
            "fromLocation": fromLocation,
            "toLocation": toLocation,
            "seats": seats,
            "date": formattedDate, // UTC formatted date
            "time": formattedTime, // Local time as string
            "donationRequested": donationRequested,
            "additionalInfo": additionalInfo
        ]
        
        let node = rideType == .reserve ? "rideReserve" : "rideRequest"
        let ref = Database.database().reference().child(node).child(ride2.id)
        ref.updateChildValues(rideDict) { error, _ in
            posting = false
            if let error = error {
                alertMessage = "Error updating ride: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Ride successfully updated!"
                showAlert = true
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


// Example usage preview
struct EditRequest_Previews: PreviewProvider {
    static var previews: some View {
        EditRequest(ride2: .constant(Ride2(id: "1", userID: "user123", fromLocation: "Location A", toLocation: "Location B", seats: "3", date: "2023-01-01", time: "12:00", donationRequested: "5", userEmail: "user@example.com", userName: "John Doe", userUsername: "johndoe", userNumber: "123456789", additionalInfo: "Some info")), rideType: .reserve)
    }
}
