//
//  Falcon_RideApp.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/13/23.
////
///

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth

// AppDelegate to initialize Firebase and set up push notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Set up push notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self

        return true
    }

    // Handle updated FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary, send token to application server.
        // For testing purposes, you can show the token in a toast or alert
        if let token = fcmToken {
            DispatchQueue.main.async {
                // Display the token to the user or log it
                print("FCM Token: \(token)")
            }
        }
    }

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response
        completionHandler()
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
func applicationDidBecomeActive(_ application: UIApplication) {
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
      } else if let token = token {
        print("FCM registration token: \(token)")
        // TODO: If necessary, send token to application server.
      }
    }
}
