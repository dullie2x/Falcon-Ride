//
//  Requests.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase

struct Ride2: Identifiable {
    var id: String
    var destination: String
    var time: String
    var date: String
    var seats: String
}

struct Request: View {
    @State private var rides = [Ride2]()
    @State private var searchText = ""
    @State private var showingAddView = false

    init() {
        fetchRideRequests()
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.darkBlue)
                    TextField("Search Rides", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.gray)
                }
                .padding()
                .cornerRadius(10)
                .padding()
                .shadow(radius: 10)
                .background(Color.white) // Search bar background color set to blue
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(rides.filter {
                            searchText.isEmpty || $0.destination.localizedCaseInsensitiveContains(searchText)
                        }) { ride in
                            NavigationLink(destination: OtherUserProfile()) {
                                RideCell2(ride: ride)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white) // Individual ride cell background color
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                    .padding()
                }
                
                NavigationLink(destination: AddView(), isActive: $showingAddView) { EmptyView() }
            }
            .navigationBarTitle("Request Ride")
            .navigationBarItems(trailing: addButton)
            .background(Color.white) // Set the entire view background color to blue
        }
        .background(Color.blue)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: fetchRideRequests)
    }

    var addButton: some View {
        Button(action: {
            showingAddView = true
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .padding()
                .foregroundColor(.darkBlue) // Button color changed to white for visibility
        }
    }

    // Function to fetch ride requests from Firebase
    func fetchRideRequests() {
        let ref = Database.database().reference().child("rideRequests") // Adjust the node name as per your database
        ref.observe(.value) { snapshot in
            self.rides.removeAll()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let destination = dict["destination"] as? String,
                   let time = dict["time"] as? String,
                   let date = dict["date"] as? String,
                   let seats = dict["seats"] as? String {
                    let ride = Ride2(id: snapshot.key, destination: destination, time: time, date: date, seats: seats)
                    self.rides.append(ride)
                }
            }
        }
    }
}

struct RideCell2: View {
    var ride: Ride2
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ride.destination)
                    .font(.headline)
                    .foregroundColor(.darkBlue)
                Text("\(ride.date) at \(ride.time)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(ride.seats) seats")
                .font(.subheadline)
                .foregroundColor(.red)
                .shadow(radius: 5)
        }
        .padding()
    }
}

struct Request_Previews: PreviewProvider {
    static var previews: some View {
        Request()
    }
}
