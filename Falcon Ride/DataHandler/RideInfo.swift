//
//  RideInfo.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/23/23.
//

import Foundation

enum RideInfo {
    case reserve(Ride)
    case request(Ride2)
}
enum RideType {
    case reserve, request
}

enum ReservationType {
    case booked(Reservation)
    case acceptedRequest(Reservation)
}


