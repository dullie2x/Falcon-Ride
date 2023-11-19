//
//  AddRequest.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase

struct AddRequestView: View {
    @State private var fromLocation = ""
    @State private var toLocation = ""
    @State private var seats = ""
    @State private var selectedDate = Date()
    @State private var donationRequested = ""
    @State private var otherDetails = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ride Details").font(.headline)) {
                    TextField("From", text: $fromLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("To", text: $toLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Number of Seats Needed", text: $seats)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section(header: Text("Date and Time").font(.headline)) {
                    DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }

                Section(header: Text("Additional Info.").font(.headline)) {
                    TextField("Donation ($, Food, Gas, None)", text: $donationRequested)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Other Details", text: $otherDetails)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button(action: postRideRequest) {
                    Text("Add Request")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .navigationBarTitle("Add Ride Request", displayMode: .inline)
            .padding(.top, -20)
        }
    }

    // Function to post a ride request to Firebase Realtime Database
    func postRideRequest() {
        let rideRequestDict: [String: Any] = [
            "fromLocation": fromLocation,
            "toLocation": toLocation,
            "seats": seats,
            "date": DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .short),
            "donationRequested": donationRequested,
            "otherDetails": otherDetails
        ]

        let ref = Database.database().reference()
        ref.child("rideRequests").childByAutoId().setValue(rideRequestDict) { (error, reference) in
            if let error = error {
                print("Error posting ride request: \(error.localizedDescription)")
            } else {
                // Reset form or handle success
            }
        }
    }
}

struct AddRequestView_Previews: PreviewProvider {
    static var previews: some View {
        AddRequestView()
    }
}
