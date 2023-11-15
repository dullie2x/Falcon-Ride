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
                Section(header: Text("Ride Details")) {
                    TextField("From", text: $fromLocation)
                    TextField("To", text: $toLocation)
                    TextField("Number of Seats", text: $seats)
                }

                Section(header: Text("Date and Time")) {
                    DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                }

                Section(header: Text("Additional Information")) {
                    TextField("Donation Requested", text: $donationRequested)
                    TextField("Other Details", text: $otherDetails)
                }

                Button(action: {
                    // Action for posting the ride request
                    print("Post Button Tapped")
                }) {
                    Text("Post")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
            }
            .navigationBarTitle("Add Request")
        }
    }
}

struct AddRequestView_Previews: PreviewProvider {
    static var previews: some View {
        AddRequestView()
    }
}
