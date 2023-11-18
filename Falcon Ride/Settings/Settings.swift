//
//  Settings.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI

struct Settings: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var number: String = ""
    @State private var snapchat: String = ""
    @State private var instagram: String = ""

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
                        // Handle Log Out
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

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
