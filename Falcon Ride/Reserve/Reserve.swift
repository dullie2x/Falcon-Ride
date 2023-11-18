//
//  HomePage.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

struct Ride {
    var destination: String
    var time: String
    var date: String
    var seats: String
}

struct Reserve: View {
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
    
    init() {
          configureNavigationBarAppearance()
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


struct Reserve_Previews: PreviewProvider {
    static var previews: some View {
        Reserve()
    }
}

