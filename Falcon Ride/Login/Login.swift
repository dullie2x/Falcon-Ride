import SwiftUI
import FirebaseAuth

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToSignUp = false
    
    @Binding var isLoggedIn: Bool

    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    // Logo
                    Image("logo1png") // Replace with your logo image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        CustomTextField(placeholder: "Email", text: $email) // Changed to String
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)

                        CustomSecureField(placeholder: "Password", text: $password) // Changed to String
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }

                    // Login Button
                    Button(action: loginUser) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }

                    // Navigation to Sign Up
                    NavigationLink(destination: SignUp(), isActive: $navigateToSignUp) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                            .underline()
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                .padding(.top, -100)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Email or password is empty."
            showingAlert = true
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Incorrect email or password"
                showingAlert = true
                print("Login error: \(error.localizedDescription)")
            } else {
                isLoggedIn = true
                print("Login successful.")
            }
        }
    }
}

// Custom Text Field
//struct CustomTextField: View {
//    var placeholder: String
//    @Binding var text: String
//    
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .padding()
//            .background(Color.white.opacity(0.8))
//            .cornerRadius(10)
//            .padding(.horizontal, 20)
//    }
//}
// Custom Secure Field
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal, 20)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(isLoggedIn: .constant(false))
    }
}
