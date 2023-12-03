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
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text("Need a break? We might miss you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)

                Button(action: {
                    logOutUser()
                }) {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }

                Spacer()

                Button(action: {
                    self.showingDeleteAlert = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("Delete Account"),
                          message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                          primaryButton: .destructive(Text("Delete")) {
                              deleteUser()
                          },
                          secondaryButton: .cancel()
                    )
                }

                Group {
                    Text("Contact Abdulmalik Ariyo on teams for any questions and feedback! Thank you!")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                        .frame(maxWidth: 300, alignment: .center)
                    Text("Ver 1.03")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.darkBlue)
                        .padding(.bottom, 20)
                        .frame(maxWidth: 300, alignment: .center)
                }
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

    private func deleteUser() {
        DataHandler.shared.deleteUserAccount { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                // You may want to show an alert here if there is an error
            } else {
                authViewModel.isUserAuthenticated = false
                // Perform any additional clean-up or navigation as needed
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
