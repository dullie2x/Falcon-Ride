//
//  TabController.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/15/23.
//

import SwiftUI

struct TabController: View {
    var body: some View {
        TabView {
            Reserve()
                .tabItem {
                    Label("Reserve", systemImage: "car.fill")
                }

            Request()
                .tabItem {
                    Label("Request", systemImage: "paperplane.fill")
                }

            Activity()
                .tabItem {
                    Label("Activity", systemImage: "person.bubble.fill")
                }
            MyProfile()
                .tabItem {
                    Label("My Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

struct TabController_Previews: PreviewProvider {
    static var previews: some View {
        TabController()
    }
}

