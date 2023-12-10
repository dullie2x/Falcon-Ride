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
        print("Firebase has been configured")

        // Set up push notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("Notification permission granted: \(granted), Error: \(String(describing: error))")
        }
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0

        Messaging.messaging().delegate = self

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        if let token = fcmToken {
            print("FCM Token: \(token)")
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification in foreground: \(notification.request.content.userInfo)")
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("Received notification response: \(response.notification.request.content.userInfo)")
        completionHandler()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
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
