//
//  Splash View.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/16/23.
//

import SwiftUI

struct SplashView: View {
    @State var isActive: Bool = false

    var body: some View {
        // Full-screen ZStack to ensure the background covers everything
        ZStack {
            Color.darkBlue // Set the background color here
                .edgesIgnoringSafeArea(.all) // Make the background color extend to the edges of the screen

            VStack {
                if self.isActive {
                    // Replace with your home screen view
                    TabController()
                } else {
                    // Replace "Logo1" with the name of your image asset
                    Image("logo1png")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

// Define an extension for the custom color
extension Color {
    static let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.7)
}

//struct SplashView_Previews: PreviewProvider {
//    static var previews: some View {
//        SplashView()
//    }
//}

struct RideCell_Previews: PreviewProvider {
    static var previews: some View {
        RideCell(ride: Ride(id: "1", userID: "User1", fromLocation: "Location A", toLocation: "Location B", seats: "2", date: "2023-01-01", time: "12:00", donationRequested: "5"), width: 300, height: 100)
    }
}

