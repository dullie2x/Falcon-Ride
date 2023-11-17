//
//  NotMyProfile.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

struct OtherUserProfileReservation: Hashable {
    var destination: String
    var date: String
    var status: String
}

struct OtherUserProfileRequest: Hashable {
    var destination: String
    var date: String
}

struct OtherUserProfile: View {
    let reservations = [
        OtherUserProfileReservation(destination: "Airport", date: "November 20, 2023", status: "Confirmed"),
        OtherUserProfileReservation(destination: "Downtown", date: "November 22, 2023", status: "Pending")
    ]
    let requests = [
        OtherUserProfileRequest(destination: "Shopping Mall", date: "November 25, 2023"),
        OtherUserProfileRequest(destination: "Restaurant", date: "November 30, 2023")
    ]

    @State private var selectedReservations = Set<OtherUserProfileReservation>()
    @State private var selectedRequests = Set<OtherUserProfileRequest>()
    
    var body: some View {
           ScrollView {
               VStack(alignment: .leading) {
                   OtherProfileHeaderView()
                       .shadow(radius: 10)
                       .padding()

                   SectionHeaderView(title: "Reservations")
                       .padding(.horizontal, 16) // Moving title away from the edge
                       .shadow(radius: 5)
                   ForEach(reservations, id: \.self) { reservation in
                       ReservationView(destination: reservation.destination, date: reservation.date)
                           .background(selectedReservations.contains(reservation) ? Color.blue.opacity(0.2) : Color.clear)
                           .cornerRadius(10)
                           .shadow(radius: 5)
                           .onTapGesture { toggleSelection(reservation) }
                           .padding(.horizontal)
                   }

                   SectionHeaderView(title: "Requests")
                       .padding(.horizontal, 16) // Moving title away from the edge
                       .shadow(radius: 5)
                   ForEach(requests, id: \.self) { request in
                       RequestView(destination: request.destination, date: request.date)
                           .background(selectedRequests.contains(request) ? Color.green.opacity(0.2) : Color.clear)
                           .cornerRadius(10)
                           .shadow(radius: 5)
                           .onTapGesture { toggleSelection(request) }
                           .padding(.horizontal)
                   }
               }

               ConfirmButton(selectedReservations: $selectedReservations, selectedRequests: $selectedRequests)
                   .shadow(radius: 10)
                   .padding()
           }
           .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
       }

       private func toggleSelection(_ reservation: OtherUserProfileReservation) {
           if selectedReservations.contains(reservation) {
               selectedReservations.remove(reservation)
           } else {
               selectedReservations.insert(reservation)
           }
       }

       private func toggleSelection(_ request: OtherUserProfileRequest) {
           if selectedRequests.contains(request) {
               selectedRequests.remove(request)
           } else {
               selectedRequests.insert(request)
           }
       }
   }

    // Redefine SectionHeaderView with a more modern look
    struct SectionHeaderView2: View {
        var title: String
        
        var body: some View {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.top, 10)
        }
    }

    // Redefine ConfirmButton with a more pronounced and aesthetic design
    struct ConfirmButton: View {
        @Binding var selectedReservations: Set<OtherUserProfileReservation>
        @Binding var selectedRequests: Set<OtherUserProfileRequest>

        var body: some View {
            Button(action: {
                // Handle confirmation action
                print("Confirmed Reservations: \(selectedReservations)")
                print("Confirmed Requests: \(selectedRequests)")
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24)) // Adjust the size of the image
                    Text("Confirm Selection")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
    }

struct OtherProfileHeaderView: View {
    var body: some View {
        HStack {
            Image("profilepic1") // Replace with the actual image
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("User 2").font(.title)
                Text("user2@user.com")
                Text("404-643-9730")
                Text("Snapchat: usER2_")
                Text("Instagram: usER2_")
            }
        }
    }
}

struct OtherUserProfile_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfile()
    }
}

