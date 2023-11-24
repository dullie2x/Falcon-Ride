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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ride Details").font(.headline)) {
                    CustomTextField(placeholder: "From", text: $fromLocation)
                    CustomTextField(placeholder: "To", text: $toLocation)
                    CustomTextField(placeholder: "Number of Seats Available", text: $seats, keyboardType: .numberPad)
                }
                
                Section(header: Text("Date and Time").font(.headline)) {
                    DatePicker("Select Date and Time", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section(header: Text("Additional Info").font(.headline)) {
                    CustomTextField(placeholder: "Donation ($, Food, Gas, None)", text: $donationRequested)
                    CustomTextField(placeholder: "Other Details", text: $additionalInfo)
                }
                
                SubmitButton(text: posting ? "Posting..." : "Add Ride", action: postRide, isLoading: $posting)
                    .disabled(!isFormValid || posting)
            }
            .navigationBarTitle("Add Ride", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    var isFormValid: Bool {
        !fromLocation.isEmpty && !toLocation.isEmpty && !seats.isEmpty && !donationRequested.isEmpty
    }

    func postRide() {
        guard isFormValid else {
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
        
        let ref = Database.database().reference()
        ref.child("rideReserve").childByAutoId().setValue(rideDict) { (error, reference) in
            posting = false
            if let error = error {
                alertMessage = "Error posting ride: \(error.localizedDescription)"
                showAlert = true
            } else {
                resetForm()
                alertMessage = "Ride successfully added!"
                showAlert = true
                presentationMode.wrappedValue.dismiss()
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

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .accessibilityLabel(placeholder)
    }
}

struct SubmitButton: View {
    var text: String
    var action: () -> Void
    @Binding var isLoading: Bool

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text(text)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
