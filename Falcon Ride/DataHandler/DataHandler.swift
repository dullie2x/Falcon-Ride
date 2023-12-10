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
    func deleteUserAccount(completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // Delete user data from database
        let userRef = Database.database().reference().child("users").child(userID)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(error)
                return
            }
            
            // Delete the user account
            Auth.auth().currentUser?.delete(completion: completion)
        }
    }
    
    
    func recordBooking(rideID: String, bookerUserID: String, providerUserID: String, type: String, completion: @escaping (Error?) -> Void) {
        let bookingData: [String: Any] = [
            "rideID": rideID,
            "bookerUserID": bookerUserID,
            "providerUserID": providerUserID,
            "type": type // "reservation" or "request"
        ]
        
        let ref = Database.database().reference()
        ref.child("bookings").childByAutoId().setValue(bookingData) { error, _ in
            completion(error)
        }
    }
    //
    //    func cancelRide(rideId: String, seatsToCancel: Int, rideType: RideType, completion: @escaping (Error?) -> Void) {
    //        // Correctly assign the node based on the rideType
    //        let node = rideType == .reserve ? "rideReserve" : "rideRequest"
    //        let rideRef = Database.database().reference().child(node).child(rideId)
    //
    //        guard let currentUserID = Auth.auth().currentUser?.uid else {
    //            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
    //            return
    //        }
    //
    //        rideRef.observeSingleEvent(of: .value) { snapshot in
    //            if var rideData = snapshot.value as? [String: Any],
    //               let currentSeats = rideData["seats"] as? String,
    //               let currentSeatsInt = Int(currentSeats) {
    //
    //                let updatedSeats = currentSeatsInt + seatsToCancel
    //                rideData["seats"] = "\(updatedSeats)"
    //                
    //                rideRef.setValue(rideData) { error, _ in
    //                    if let error = error {
    //                        completion(error)
    //                        return
    //                    }
    //
    //                    self.recordCancellationInActivityFeed(rideId: rideId, userId: currentUserID, rideType: rideType) { error in
    //                        completion(error)
    //                    }
    //                }
    //            } else {
    //                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ride not found"]))
    //            }
    //        }
    //    }
    
    func cancelRide(bookingId: String, seatsToCancel: Int, completion: @escaping (Error?) -> Void) {
        let bookingsRef = Database.database().reference().child("bookings").child(bookingId)
        
        bookingsRef.observeSingleEvent(of: .value) { snapshot in
            if let bookingData = snapshot.value as? [String: Any],
               let rideId = bookingData["rideID"] as? String,
               let rideType = bookingData["type"] as? String,
               let bookerUserID = bookingData["bookerUserID"] as? String {
                
                let node = rideType == "reservation" ? "rideReserve" : "rideRequest"
                let rideRef = Database.database().reference().child(node).child(rideId)
                
                rideRef.observeSingleEvent(of: .value) { snapshot in
                    if var rideData = snapshot.value as? [String: Any],
                       let currentSeats = rideData["seats"] as? String,
                       let currentSeatsInt = Int(currentSeats),
                       let posterUserID = rideData["userID"] as? String {
                        
                        let updatedSeats = currentSeatsInt + seatsToCancel
                        rideData["seats"] = "\(updatedSeats)"
                        
                        rideRef.setValue(rideData) { error, _ in
                            if let error = error {
                                completion(error)
                                return
                            }
                            
                            // Delete the booking
                            bookingsRef.removeValue()
                            
                            // Record cancellation in activity feed for both users
                            self.recordCancellationInActivityFeed(rideId: rideId, userId: bookerUserID, rideType: rideType == "reservation" ? .reserve : .request) { error in
                                if let error = error {
                                    completion(error)
                                    return
                                }
                                
                                self.recordCancellationInActivityFeed(rideId: rideId, userId: posterUserID, rideType: rideType == "reservation" ? .reserve : .request) { error in
                                    completion(error)
                                }
                            }
                        }
                    } else {
                        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ride not found"]))
                    }
                }
            } else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Booking not found"]))
            }
        }
    }
    
    private func recordCancellationInActivityFeed(rideId: String, userId: String, rideType: RideType, completion: @escaping (Error?) -> Void) {
        let activityRef = Database.database().reference().child("activityFeed")
        let messagePrefix = userId == Auth.auth().currentUser?.uid ? "Your ride" : "Ride"
        let activityData: [String: Any] = [
            "rideId": rideId,
            "userId": userId,
            "message": "\(messagePrefix) \(rideType == .reserve ? "reservation" : "request") cancelled",
            "timestamp": Date().timeIntervalSince1970  // Record the current timestamp
        ]
        
        activityRef.childByAutoId().setValue(activityData) { error, _ in
            completion(error)
        }
    }
    
    
}


