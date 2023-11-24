//
//  SwiftUIView.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/23/23.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        Button(action: {
        }) {
            Text("Confirm Booking")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: 200, minHeight: 50) // Make button full width
                .background(Color.darkBlue)
                .cornerRadius(15)
                .padding(.horizontal)
        }
        .shadow(radius: 5) // Add shadow
    }
}

#Preview {
    SwiftUIView()
}
