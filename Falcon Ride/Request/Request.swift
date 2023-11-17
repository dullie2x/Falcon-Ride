//
//  Requests.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

struct Ride2 {
    var destination: String
    var time: String
    var date: String
    var seats: String
}

struct Request: View {
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

    @State private var searchText = ""
    @State private var showingAddView = false

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // List of rides
                List(rides.filter {
                    searchText.isEmpty || $0.destination.localizedCaseInsensitiveContains(searchText)
                }, id: \.destination) { ride in
                    RideCell(ride: ride)
                }

                NavigationLink(destination: AddRequestView(), isActive: $showingAddView) { EmptyView() }
            }
            .navigationBarTitle("Ride requests")
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddView = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding()
                }
            )
        }
    }
}

struct Ride2Cell: View {
    var ride: Ride

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ride.destination)
                    .font(.headline)
                Text("\(ride.date) at \(ride.time)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(ride.seats) seats")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

struct Request_Previews: PreviewProvider {
    static var previews: some View {
        Request()
    }
}
