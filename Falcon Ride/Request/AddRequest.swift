//
//  AddRequest.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

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

                Button(action: {
                    // Action for posting the ride request
                    print("Post Button Tapped")
                }) {
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
            //.navigationBarTitle("Add Ride", displayMode: .inline)
            .padding(.top, -20)
            //.edgesIgnoringSafeArea(.top)
        }
    }
}

struct AddRequestView_Previews: PreviewProvider {
    static var previews: some View {
        AddRequestView()
    }
}
