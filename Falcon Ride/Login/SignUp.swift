import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct SignUp: View {
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var number: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
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
                TextField("First Name", text: $name)
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
                
                // Phone Number Field
                TextField("Phone Number", text: $number)
                    .keyboardType(.numberPad)
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
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Sign Up Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func signUpUser() {
        guard password == confirmPassword, !username.isEmpty, !email.isEmpty, !name.isEmpty, !number.isEmpty else {
            alertMessage = "Please ensure all fields are filled and passwords match."
            showingAlert = true
            return
        }
        
        checkUniqueUserDetails { isUnique in
            if isUnique {
                // Create a new user
                Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
                    if let error = error {
                        self.alertMessage = error.localizedDescription
                        self.showingAlert = true
                    } else if let userID = authResult?.user.uid {
                        // Success: Save user profile
                        DataHandler.shared.saveUserProfile(userID: userID, email: self.email, name: self.name, number: self.number, username: self.username) { error in
                            if let error = error {
                                self.alertMessage = "Error saving user profile: \(error.localizedDescription)"
                                self.showingAlert = true
                            } else {
                                // Profile saved successfully
                                // Navigate to the next screen or show a success message
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkUniqueUserDetails(completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference().child("users")
        ref.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.alertMessage = "Email already in use. Please use a different email."
                self.showingAlert = true
                completion(false)
            } else {
                ref.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        self.alertMessage = "Username already taken. Please choose a different username."
                        self.showingAlert = true
                        completion(false)
                    } else {
                        completion(true)
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
