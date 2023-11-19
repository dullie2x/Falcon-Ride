//
//  SignUp.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUp: View {
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        ZStack {
            Color.darkBlue // Set the background color here
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                // Logo
                Image("logo1png")  // Replace with your logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                
                // Name Field
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                // Email Field
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                // Username Field
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                // Confirm Password Field
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                
                // Sign Up Button
                Button(action: signUpUser) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationBarTitle("Sign Up", displayMode: .inline)
            .padding(.top, -100)
        }
    }
    
    // Function to handle user sign up
    func signUpUser() {
        // Validate inputs
        guard password == confirmPassword, !username.isEmpty, !email.isEmpty, !name.isEmpty else {
            // Handle error: Show an alert or message to the user
            return
        }
        
        // Create a new user
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle error: Show an alert or message to the user
                print(error.localizedDescription)
            } else if let userID = authResult?.user.uid {
                // Success: Save user profile
                DataHandler.shared.saveUserProfile(userID: userID, email: email, name: name, username: username) { error in
                    if let error = error {
                        // Handle error: Show an alert or message to the user
                        print("Error saving user profile: \(error.localizedDescription)")
                    } else {
                        // Profile saved successfully
                        // Navigate to the next screen or show a success message
                    }
                }
            }
        }
    }
}


struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
