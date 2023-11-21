//
//  AddPost.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct AddView: View {
    @State private var fromLocation = ""
    @State private var toLocation = ""
    @State private var seats = ""
    @State private var selectedDate = Date()
    @State private var donationRequested = ""
    @State private var additionalInfo = ""
    @State private var posting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ride Details").font(.headline)) {
                    TextField("From", text: $fromLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("To", text: $toLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Number of Seats Available", text: $seats)
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
                    TextField("Other Details", text: $additionalInfo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: postRide) {
                    Text(posting ? "Posting..." : "Add Ride")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(posting)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .navigationBarTitle("Add Ride", displayMode: .inline)
            .padding(.top, -20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Function to post a ride to Firebase Realtime Database
    func postRide() {
        guard !fromLocation.isEmpty, !toLocation.isEmpty, !seats.isEmpty, !donationRequested.isEmpty else {
            alertMessage = "Please fill all fields."
            showAlert = true
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        posting = true
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: selectedDate)

        let rideDict: [String: Any] = [
            "userID": userID,
            "fromLocation": fromLocation,
            "toLocation": toLocation,
            "seats": seats,
            "time": timeString,
            "date": ISO8601DateFormatter().string(from: selectedDate),
            "donationRequested": donationRequested,
            "additionalInfo": additionalInfo
        ]
        
        // Reference to the Firebase Database
        let ref = Database.database().reference()
        
        // Posting the ride under the 'rideReserve' node to match your fetch function
        ref.child("rideReserve").childByAutoId().setValue(rideDict) { (error, reference) in
            posting = false
            if let error = error {
                alertMessage = "Error posting ride: \(error.localizedDescription)"
                showAlert = true
            } else {
                resetForm()
                alertMessage = "Ride successfully added!"
                showAlert = true
            }
        }
    }

    
    func resetForm() {
        fromLocation = ""
        toLocation = ""
        seats = ""
        selectedDate = Date()
        donationRequested = ""
        additionalInfo = ""
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
