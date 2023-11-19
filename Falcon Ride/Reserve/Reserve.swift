//
//  HomePage.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase

struct Ride: Identifiable {
    var id: String
    var fromLocation: String
    var toLocation: String
    var seats: String
    var date: String
}

struct Reserve: View {
    @State private var rides = [Ride]()
    @State private var searchText = ""
    @State private var showingAddView = false

    init() {
        configureNavigationBarAppearance()
        fetchRides()
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
                            searchText.isEmpty || $0.toLocation.localizedCaseInsensitiveContains(searchText)
                        }) { ride in
                            NavigationLink(destination: OtherUserProfile()) {
                                RideCell(ride: ride)
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
            .navigationBarTitle("Available Rides", displayMode: .automatic)
            .navigationBarItems(trailing: addButton)
            .background(Color.white)
        }
        .background(Color.blue)
        .navigationViewStyle(StackNavigationViewStyle())
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

    // Function to fetch rides from Firebase
    func fetchRides() {
        let ref = Database.database().reference().child("rides")
        ref.observe(.value) { snapshot in
            rides.removeAll()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let fromLocation = dict["fromLocation"] as? String,
                   let toLocation = dict["toLocation"] as? String,
                   let seats = dict["seats"] as? String,
                   let date = dict["date"] as? String {
                    let ride = Ride(id: snapshot.key, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: date)
                    rides.append(ride)
                }
            }
        }
    }
}

private func configureNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // This color adapts to light/dark mode
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
}

struct RideCell: View {
    var ride: Ride
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ride.toLocation)
                    .font(.headline)
                    .foregroundColor(.darkBlue) // Text color changed to white for visibility
                Text("\(ride.date) - \(ride.seats) seats")
                    .font(.subheadline)
                    .foregroundColor(.gray) // Text color changed to white for visibility
            }
            Spacer()
        }
        .padding()
    }
}

struct Reserve_Previews: PreviewProvider {
    static var previews: some View {
        Reserve()
    }
}
