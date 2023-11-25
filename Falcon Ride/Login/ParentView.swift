//
//  ParentView.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/19/23.
//

import SwiftUI

struct ParentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        if authViewModel.isUserAuthenticated {
            SplashView()
                .environmentObject(authViewModel)
        } else {
            Login(isLoggedIn: $authViewModel.isUserAuthenticated)
        }
    }
}

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
            .environmentObject(AuthenticationViewModel())
    }
}

