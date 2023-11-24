//
//  DataHandler.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/19/23.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DataHandler {
    static let shared = DataHandler()

    private init() {}

    // Save or update user profile
    func saveUserProfile(userID: String, email: String, name: String, number: String?, username: String, completion: @escaping (Error?) -> Void) {
        let userRef = Database.database().reference().child("users").child(userID)
        let userData = ["email": email, "name": name, "username": username, "number": number]
        userRef.setValue(userData) { error, _ in
            completion(error)
        }
    }
    
    // Post a new ride to the rideReserve node
    func postRideReserve(fromLocation: String, toLocation: String, date: String, time: String, seats: String, donationRequested: String, additionalInfo: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let rideDict: [String: Any] = [
            "userID": userID,
            "fromLocation": fromLocation,
            "toLocation": toLocation,
            "date": date,
            "time": time,
            "seats": seats,
            "donationRequested": donationRequested,
            "additionalInfo": additionalInfo
        ]

        let ref = Database.database().reference()
        ref.child("rideReserve").childByAutoId().setValue(rideDict) { error, _ in
            completion(error)
        }
    }

    // Post a new ride request to the rideRequest node
    func postRideRequest(fromLocation: String, toLocation: String, date: String, time: String, seats: String, donationRequested: String, additionalInfo: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let requestDict: [String: Any] = [
            "userID": userID,
            "fromLocation": fromLocation,
            "toLocation": toLocation,
            "date": date,
            "time": time,
            "seats": seats,
            "donationRequested": donationRequested,
            "additionalInfo": additionalInfo
        ]

        let ref = Database.database().reference()
        ref.child("rideRequest").childByAutoId().setValue(requestDict) { error, _ in
            completion(error)
        }
    }
    func deleteRide(rideId: String, node: String, completion: @escaping (Error?) -> Void) {
        let ref = Database.database().reference().child(node).child(rideId)
        ref.removeValue { error, _ in
            completion(error)
        }
    }
}


