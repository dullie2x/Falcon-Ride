//
//  Profile.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI

struct MyProfile: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) { // Align everything to the left
                HStack {
                    Button(action: {
                        // Action for settings button
                        print("Settings Tapped")
                    }) {
                        Image(systemName: "gear")
                            .font(.title)
                    }
                    .padding(.leading, 16) // Push the settings button to the left
                    Spacer() // Push the title to the right
                }
                Text("Profile")
                    .font(.largeTitle)
                    .padding(.top, 10)

                Spacer().frame(height: 20)

                HStack(alignment: .top) { // Align user picture and info to the left
                    Image("user_profile_image") // Replace with the actual image
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name: User 1")
                        Text("Email: user1@user.com")
                        Text("Number: 555-2312")
                        Text("Snapchat: usER1_")
                        Text("Instagram: usER1_")
                    }
                    .padding(.leading, 16) // Push user info to the left
                }
                .padding(.bottom, 20)

                Text("Reservations")
                    .font(.title)
                    .padding(.top, 20)

                // Example reservations
                VStack(alignment: .leading) {
                    Text("Destination: Airport")
                    Text("Date: November 20, 2023")
                    Text("Status: Confirmed")
                        .foregroundColor(.green)
                }
                .padding(.leading, 16) // Push reservations to the left
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

                VStack(alignment: .leading) {
                    Text("Destination: Downtown")
                    Text("Date: November 22, 2023")
                    Text("Status: Pending")
                        .foregroundColor(.orange)
                }
                .padding(.leading, 16) // Push reservations to the left
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

                Text("Requests")
                    .font(.title)
                    .padding(.top, 20)

                // Example requests
                VStack(alignment: .leading) {
                    Text("Destination: Shopping Mall")
                    Text("Date: November 25, 2023")
                }
                .padding(.leading, 16) // Push requests to the left
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

                VStack(alignment: .leading) {
                    Text("Destination: Restaurant")
                    Text("Date: November 30, 2023")
                }
                .padding(.leading, 16) // Push requests to the left
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct MyProfile_Previews: PreviewProvider {
    static var previews: some View {
        MyProfile()
    }
}
