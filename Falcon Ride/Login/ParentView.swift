//
//  ParentView.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/19/23.
//

import SwiftUI

struct ParentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var isActive = false

    var body: some View {
        Group {
            if authViewModel.isUserAuthenticated {
                if isActive {
                    // Directly transition to TabController
                    TabController()
                } else {
                    // Show SplashView initially
                    SplashView()
                }
            } else {
                Login(isLoggedIn: $authViewModel.isUserAuthenticated)
            }
        }
        .onAppear {
            // Start a timer to transition from SplashView to TabController
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
            .environmentObject(AuthenticationViewModel())
    }
}
