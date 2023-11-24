//
//  Falcon_RideApp.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/13/23.
////
///

import SwiftUI
import FirebaseCore
import FirebaseAuth

// AppDelegate to initialize Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Falcon_RideApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ParentView()
                .environmentObject(authViewModel)
                .environment(\.colorScheme, .light) // Override to always use light mode
        }
    }
}

class AuthenticationViewModel: ObservableObject {
    @Published var isUserAuthenticated: Bool

    init() {
        isUserAuthenticated = Auth.auth().currentUser != nil
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isUserAuthenticated = (user != nil)
        }
    }
}
