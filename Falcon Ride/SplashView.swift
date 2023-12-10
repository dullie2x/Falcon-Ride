//
//  Splash View.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/16/23.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.darkBlue.edgesIgnoringSafeArea(.all) // Background color

            // Splash logo
            Image("logo1png")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
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




