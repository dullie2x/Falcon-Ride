//
//  Settings.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI
import FirebaseAuth

struct Settings: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Need a break? We might miss you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                Button(action: {
                    logOutUser()
                }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        .shadow(radius: 5)
                }
                Spacer()
            }
            .navigationBarTitle("Settings", displayMode: .inline)
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
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(AuthenticationViewModel()) // For previews
    }
}
