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
                        ProfileHeaderView(name: userName, username: userUsername, number: userNumber, width: 400, height: 200)
                            .shadow(radius: 10)
                            .padding()
                    }
                    .padding()
                }

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

                NavigationLink(destination: Settings(), isActive: $navigateToSettings) { EmptyView() }
            }
            .navigationBarTitle("My Profile", displayMode: .inline)
            .navigationBarItems(trailing: SettingsButton(action: { navigateToSettings = true }))
            .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
            .onAppear(perform: fetchUserData)
        }
    }
}

struct ProfileHeaderView: View {
    var name: String
    var username: String
    var number: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name
            Text(name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.black)

            // Username
            Text("@\(username)")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(Color.darkBlue)

            // Number
            Text(number)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(Color.black)

            // Stylish Divider
            Divider().background(Color.darkBlue)

            // Additional User Info or Actions
            HStack {
                Spacer()
//                Button(action: /* Action for Edit */ {}) {
//                    Label("Edit Profile (coming soon)", systemImage: "pencil")
//                }
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
            }
        }
        .padding()
        .frame(width: width, height: height)
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
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
