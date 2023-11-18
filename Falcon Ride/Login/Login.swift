//
//  Login.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/17/23.
//

import SwiftUI

struct Login: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var logoOffset: CGFloat = -100
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.darkBlue // Set the background color here
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                // Logo Animation
                Image("logo1png")  // Replace with your actual logo asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                    .offset(x: logoOffset, y: 0)
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoOffset)
                    .onAppear {
                        logoOffset = 100
                    }
                
                VStack(spacing: 15) {
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
                    
                    // Login Button
                    Button(action: {
                        // Handle login action
                    }) {
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
                
                // Sign Up Prompt and Button
                VStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    Button(action: {
                        // Handle sign up action
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
                }
                
                Spacer()
            }
            .padding(.top, -250)
        }
    }
}
struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
