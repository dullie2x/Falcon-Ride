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
            ScrollView {
                VStack(alignment: .leading) {
                    ProfileHeaderView()
                        .shadow(radius: 10)
                        .padding()

                    SectionHeaderView(title: "Reservations")
                        .padding(.horizontal, 16)
                        .shadow(radius: 5)
                    ReservationView(destination: "DIA", date: "November 20, 2023")
                        .padding(.horizontal)
                        .shadow(radius: 5)
                    ReservationView(destination: "BREC", date: "November 22, 2023")
                        .padding(.horizontal)
                        .shadow(radius: 5)

                    SectionHeaderView(title: "Requests")
                        .padding(.horizontal, 16)
                        .shadow(radius: 5)
                    RequestView(destination: "COS", date: "November 25, 2023")
                        .padding(.horizontal)
                        .shadow(radius: 5)
                    RequestView(destination: "DIA", date: "November 30, 2023")
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
                .padding()
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
            .navigationBarItems(trailing: SettingsButton())
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
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
                .shadow(radius: 5)
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

struct SectionHeaderView: View {
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

// Define ReservationView, RequestView, SettingsButton as per your design


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

