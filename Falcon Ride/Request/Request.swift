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
                          }, id: \.destination) { ride in
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
              .navigationBarTitle("Request Ride")
              .navigationBarItems(trailing: addButton)
              .background(Color.white) // Set the entire view background color to blue
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
  }

  struct RideCell2: View {
      var ride: Ride
      
      var body: some View {
          HStack {
              VStack(alignment: .leading) {
                  Text(ride.destination)
                      .font(.headline)
                      .foregroundColor(.darkBlue) // Text color changed to white for visibility
                  Text("\(ride.date) at \(ride.time)")
                      .font(.subheadline)
                      .foregroundColor(.gray) // Text color changed to white for visibility
              }
              Spacer()
              Text("\(ride.seats) seats")
                  .font(.subheadline)
                  .foregroundColor(.red) // Keep or change as per your design
                  .shadow(radius: 5)
          }
          .padding()
      }
  }

// RIDE DETAILS
//struct RideDetailView: View {
//    var ride: Ride
//
//    var body: some View {
//        VStack {
//            Text("Destination: \(ride.destination)")
//                .font(.title)
//            Text("Date: \(ride.date)")
//            Text("Time: \(ride.time)")
//            Text("Seats: \(ride.seats)")
//        }.background(Color.darkBlue)
//
//        .navigationBarTitle("Ride Details", displayMode: .inline)
//
//    }
//}


struct Request_Previews: PreviewProvider {
    static var previews: some View {
        Request()
    }
}
