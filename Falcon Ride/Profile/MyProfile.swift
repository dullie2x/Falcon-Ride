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
            ScrollView { // Use ScrollView for content that may exceed screen size
                VStack(alignment: .leading) {
                    ProfileHeaderView()
                    
                    //UserInfoView()
                      //  .padding(.horizontal)
                        //   .padding(.top, 20)

                    SectionHeaderView(title: "Reservations")
                    ReservationView(destination: "DIA", date: "November 20, 2023")
                    ReservationView(destination: "BREC", date: "November 22, 2023")

                    SectionHeaderView(title: "Requests")
                    RequestView(destination: "COS", date: "November 25, 2023")
                    RequestView(destination: "DIA", date: "November 30, 2023")
                }
                .padding()
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
            .navigationBarItems(trailing: SettingsButton())
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        HStack {
            Image("logo1png") // Replace with the actual image
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .padding(.trailing, 16)

            VStack(alignment: .leading, spacing: 8) {
                Text("User 1").font(.title)
                Text("user1@user.com")
                Text("404-643-9730")
                Text("Snapchat: usER1_")
                Text("Instagram: usER1_")
            }
        }
    }
}

//struct UserInfoView: View {
  //  var body: some View {
        // Additional user information can be placed here
    //    Text("More User Info")
      //      .frame(maxWidth: .infinity, alignment: .leading)
   // }
//}

struct SectionHeaderView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .padding(.vertical, 10)
    }
}

struct ReservationView: View {
    var destination: String
    var date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Destination: \(destination)")
                Text("Date: \(date)")
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
}

struct RequestView: View {
    var destination: String
    var date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Destination: \(destination)")
                Text("Date: \(date)")
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
}

struct SettingsButton: View {
    var body: some View {
        Button(action: {
            // Action for settings button
            print("Settings Tapped")
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

struct MyProfile_Previews: PreviewProvider {
    static var previews: some View {
        MyProfile()
    }
}

