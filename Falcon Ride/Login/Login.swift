//
//  Login.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI
import FirebaseAuth

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var logoOffset: CGFloat = -100
    @State private var navigateToSignUp = false  // State for controlling navigation to SignUp view
    
    
    @Binding var isLoggedIn: Bool  // Add this line

        // Initialize with a Binding variable
        init(isLoggedIn: Binding<Bool>) {
            self._isLoggedIn = isLoggedIn
        }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBlue // Replace with your actual color
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
//                    // Logo Animation
//                    Image("logo1png") // Replace with your actual logo asset name
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 80, height: 80)
//                        .padding()
//                        .offset(x: logoOffset, y: 0)
//                        .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoOffset)
//                        .onAppear {
//                            logoOffset = 100
//                        }
                    
                    VStack(spacing: 15) {
                        // Username Field
                        TextField("Email", text: $email)
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
                        
                        // Login Button
                        Button(action: loginUser) {
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    // Sign Up Prompt and Button for Navigation
                    VStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        Button(action: {
                            navigateToSignUp = true
                        }) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        
                        // Invisible NavigationLink for programmatic navigation
                        NavigationLink(destination: SignUp(), isActive: $navigateToSignUp) { EmptyView() }
                    }
                    
                    Spacer()
                }
                .padding(.top, -250)
            }
        }
    }
    
    func loginUser() {
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            print("Error: Username or password is empty.")
            return
        }
        
        // Sign in the user
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle error
                print("Login error: \(error.localizedDescription)")
            } else {
                // Success
                print("Login successful.")
                // Proceed with the next steps after successful login
            }
        }
    }
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy binding for the preview
        Login(isLoggedIn: .constant(false))
    }
}
