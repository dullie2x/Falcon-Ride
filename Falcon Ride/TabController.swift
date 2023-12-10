//
//  TabController.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/15/23.
//

//import SwiftUI
//
//// Define the Tab enumeration as per your CustomTabBar
//enum Tab: String, CaseIterable {
//    case reserve = "car"
//    case request = "paperplane"
//    case activity = "exclamationmark.bubble"
//    case profile = "person.crop.circle"
//}
//
//// CustomTabBar as you defined in CustomTabBar.swift
//struct CustomTabBar: View {
//    @Binding var selectedTab: Tab
//    private var fillImage: String {
//        selectedTab.rawValue + ".fill"
//    }
//    private var tabColor: Color {
//        switch selectedTab {
//        case .reserve:
//            return .blue
//        case .request:
//            return .indigo
//        case .activity:
//            return .purple
//        case .profile:
//            return .green
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                ForEach(Tab.allCases, id: \.rawValue) { tab in
//                    Spacer()
//                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
//                        .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
//                        .foregroundColor(tab == selectedTab ? tabColor : .gray)
//                        .font(.system(size: 25))
//                        .onTapGesture {
//                            withAnimation(.easeInOut(duration: 0.01)) {
//                                selectedTab = tab
//                            }
//                        }
//                    Spacer()
//                }
//            }
//            .frame(width: nil, height: 60)
//            .background(.thinMaterial)
//            .cornerRadius(20)
//            .padding(10)
//        }
//    }
//}
//
//// TabController with CustomTabBar integrated
//struct TabController: View {
//    @State private var selectedTab: Tab = .reserve
//
//    var body: some View {
//        ZStack {
//            // Content of the tabs
//            TabView(selection: $selectedTab) {
//                NavigationView {
//                    Reserve()
//                }
//                .tag(Tab.reserve)
//                .tabItem {
//                    if selectedTab == .reserve {
//                        Image(systemName: "car.fill")
//                        Text("Reserve")
//                    } else {
//                        EmptyView()
//                    }
//                }
//
//                NavigationView {
//                    Request()
//                }
//                .tag(Tab.request)
//                .tabItem {
//                    if selectedTab == .request {
//                        Image(systemName: "paperplane.fill")
//                        Text("Request")
//                    } else {
//                        EmptyView()
//                    }
//                }
//
//                NavigationView {
//                    Activity()
//                }
//                .tag(Tab.activity)
//                .tabItem {
//                    if selectedTab == .activity {
//                        Image(systemName: "exclamationmark.bubble.fill")
//                        Text("Activity")
//                    } else {
//                        EmptyView()
//                    }
//                }
//
//                NavigationView {
//                    MyProfile()
//                }
//                .tag(Tab.profile)
//                .tabItem {
//                    if selectedTab == .profile {
//                        Image(systemName: "person.crop.circle.fill")
//                        Text("Profile")
//                    } else {
//                        EmptyView()
//                    }
//                }
//            }
//
//            // Custom Tab Bar
//            VStack {
//                Spacer()
//                CustomTabBar(selectedTab: $selectedTab)
//                .padding(.bottom, -15)
//            }
//        }
//    }
//}
//
//// Replace these with your actual view components
//
//struct TabController_Previews: PreviewProvider {
//    static var previews: some View {
//        TabController()
//    }
//}

import SwiftUI

struct TabController: View {
    var body: some View {
        ZStack {
            // Content of the tabs
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
                        Label("Activity", systemImage: "exclamationmark.bubble")
                    }

                MyProfile()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            .background(BlurView(style: .extraLight))
            
        }
    }
}

struct TabController_Previews: PreviewProvider {
    static var previews: some View {
        TabController()
    }
}

// BlurView.swift (for background blur effect)

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}

