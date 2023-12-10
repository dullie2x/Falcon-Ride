//
//  Profile.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth


struct MyProfile: View {
    @State private var navigateToSettings = false
    @State private var userName = "Loading..."
    @State private var userUsername = "Loading..."
    @State private var userNumber = "Loading..."
    
    @State private var selectedSegment = 0
    
    // Fetch user data
    private func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let userRef = Database.database().reference().child("users").child(userID)
        
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: AnyObject] else {
                print("No user data found")
                return
            }
            
            let name = value["name"] as? String ?? "Unknown"
            let username = value["username"] as? String ?? "Unknown"
            let number = value["number"] as? String ?? "Unknown"
            
            DispatchQueue.main.async {
                self.userName = name
                self.userUsername = username
                self.userNumber = number
            }
        }) { error in
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ProfileHeaderView(name: userName, username: userUsername, number: userNumber)
                            .padding()
                        
                        // Segmented Control
                        Picker("Options", selection: $selectedSegment) {
                            Text("Reservations").tag(0)
                            Text("Rides").tag(1)
                            Text("Requests").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Conditional Views for Reservations, Posts, and Requests
                        switch selectedSegment {
                        case 0:
                            ReservationsView() // Placeholder for ReservationsView
                        case 1:
                            PostsView() // Placeholder for PostsView
                        case 2:
                            RequestsView() // Placeholder for RequestsView
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // Contact and Version Information
                
                
                NavigationLink(destination: Settings(), isActive: $navigateToSettings) { EmptyView() }
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
            .navigationBarItems(trailing: SettingsButton(action: { navigateToSettings = true }))
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
            .onAppear(perform: fetchUserData)
        }
        .background(Color.background) // Add a background color or image here
    }
}

struct ProfileHeaderView: View {
    var name: String
    var username: String
    var number: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
            
            // Username
            Text("@\(username)")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(Color.darkBlue)
            
            // Number
            Text(number)
                .font(.title2)
                .foregroundColor(Color.black)
            
            // Stylish Divider
            Divider().background(Color.darkBlue)
            
            // Additional User Info or Actions
            HStack {
                Spacer()
                // Add your Edit Profile button here if needed
                Spacer()
            }
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding()
    }
}

struct SettingsButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
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

extension Color {
    static let background = Color.gray.opacity(0.2) // Set your desired background color here
}
