//
//  Requests.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

// Dummy model for a ride
struct Ride2 {
    var destination: String
    var time: String
    var date: String
    var seats: String
}

struct Request: View {
    // Sample data for available rides
    let rides = [
        Ride(destination: "DIA", time: "2:00 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "COS", time: "2:30 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "BREC", time: "3:00 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "DIA", time: "2:00 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "COS", time: "2:30 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "BREC", time: "3:00 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "DIA", time: "2:00 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "COS", time: "2:30 PM", date: "Nov 2", seats: "3"),
        Ride(destination: "BREC", time: "3:00 PM", date: "Nov 2", seats: "3")
    ]

    @State private var searchText = "" // Add a state variable for search text

    var body: some View {
        NavigationView {
            List {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass") // Search icon
                    TextField("Search", text: $searchText) // Search text field
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)

                ForEach(rides.filter {
                    searchText.isEmpty || $0.destination.localizedCaseInsensitiveContains(searchText)
                }, id: \.destination) { ride2 in
                    VStack(alignment: .leading) {
                        Text(ride2.destination)
                            .font(.headline)
                        Text(ride2.time)
                            .font(.subheadline)
                        Text(ride2.date)
                            .font(.subheadline)
                        Text("Seats available: \(ride2.seats)")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationBarTitle("Available Rides")
            .navigationBarItems(trailing:
                Button(action: {
                    // Action for adding a new ride
                    print("Add Ride Tapped")
                }) {
                    Image(systemName: "plus.app")
                }
            )
        }
    }
}
struct Request_Previews: PreviewProvider {
    static var previews: some View {
        Request()
    }
}
