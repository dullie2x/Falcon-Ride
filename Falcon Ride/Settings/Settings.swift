//
//  Settings.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI
import FirebaseAuth

struct Settings: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var number: String = ""
    @State private var snapchat: String = ""
    @State private var instagram: String = ""
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile").font(.headline)) {
                    SettingTextField(title: "Username", text: $username)
                    SettingTextField(title: "Email", text: $email)
                    SettingTextField(title: "Number", text: $number)
                    SettingTextField(title: "Snapchat", text: $snapchat)
                    SettingTextField(title: "Instagram", text: $instagram)
                }
                
                Section {
                    Button(action: {
                        logOutUser()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .shadow(radius: 5)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: SaveButton())
        }
    }
    
    private func logOutUser() {
        do {
            try Auth.auth().signOut()
            authViewModel.isUserAuthenticated = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    struct SettingTextField: View {
        var title: String
        @Binding var text: String
        
        var body: some View {
            HStack {
                Text(title + ":")
                    .foregroundColor(.secondary)
                TextField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    struct SaveButton: View {
        var body: some View {
            Button(action: {
                // Handle save action
            }) {
                Text("Save")
                    .fontWeight(.bold)
                    .shadow(radius: 5)
            }
        }
    }
}
    struct Settings_Previews: PreviewProvider {
        static var previews: some View {
            Settings()
                .environmentObject(AuthenticationViewModel()) // For previews
        }
    }
