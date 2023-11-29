//
//  Requests.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct Ride2: Identifiable {
    var id: String
    var userID: String
    var fromLocation: String
    var toLocation: String
    var seats: String
    var date: String
    var time: String
    var donationRequested: String
    var userEmail: String?
    var userName: String?
    var userUsername: String?
    var userNumber: String?
    var additionalInfo: String?
}

struct Request: View {
    @State private var rides2 = [Ride2]()
    @State private var searchText = ""
    @State private var showingAddRequestView = false
    @State private var isLoading2 = true
    
    
    init() {
        configureNavigationBarAppearance()
        fetchRides2()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.darkBlue)
                    TextField("Search Rides", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.gray)
                }
                .padding()
                .cornerRadius(10)
                .padding()
                .shadow(radius: 10)
                .background(Color.white) // Search bar background color set to blue
                
                ScrollView {
                    VStack(spacing: 10) {
                        if isLoading2 {
                            ForEach(0..<5, id: \.self) { _ in
                                RideCellSkeleton2(width: 400, height: 200)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        } else {
                            ForEach(rides2.filter {
                                searchText.isEmpty || $0.fromLocation.localizedCaseInsensitiveContains(searchText) || $0.toLocation.localizedCaseInsensitiveContains(searchText)
                            }) { ride2 in
                                NavigationLink(destination: OtherUserProfile(rideInfo: .request(ride2), additionalInfo: ride2.additionalInfo ?? "")) {
                                    RideCell2(ride2: ride2, width: 300, height: 100, onDelete: { selectedRide in
                                        // Deletion logic goes here
                                        DataHandler.shared.deleteRide(rideId: selectedRide.id, node: "rideRequest") { error in
                                            // Handle error or success
                                        }
                                    })
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding()
                }
                
                NavigationLink(destination: AddRequestView(), isActive: $showingAddRequestView) { EmptyView() }
            }
            .navigationBarTitle("Requests", displayMode: .automatic)
            .navigationBarItems(trailing: addButton)
            .background(Color.white)
            .onAppear(perform: fetchRides2)
        }
        .background(Color.blue)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var addButton: some View {
        Button(action: {
            showingAddRequestView = true
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .padding()
                .foregroundColor(.darkBlue) // Button color changed to white for visibility
        }
    }
    
    // Function to fetch rides from Firebase
    func fetchRides2() {
        let currentUserID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let ridesRef = ref.child("rideRequest")
        let usersRef = ref.child("users")
        
        ridesRef.observe(.value) { snapshot in
            var newRides2: [Ride2] = []
            
            if snapshot.childrenCount == 0 {
                print("No rides found in Firebase.")
                self.isLoading2 = false
                return
            }
            
            let group = DispatchGroup()
            
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let dict = snapshot.value as? [String: Any],
                      let userID = dict["userID"] as? String,
                      let fromLocation = dict["fromLocation"] as? String,
                      let toLocation = dict["toLocation"] as? String,
                      let seats = dict["seats"] as? String,
                      let dateString = dict["date"] as? String,
                      let timeString = dict["time"] as? String,
                      let donationRequested = dict["donationRequested"] as? String,
                      let additionalInfo = dict["additionalInfo"] as? String else {
                    print("Error parsing fields in ride data")
                    continue
                }
                
                let formattedDate = formatDate(dateString: dateString)
                let formattedTime = formatTime(timeString: timeString)
                
                group.enter()
                usersRef.child(userID).observeSingleEvent(of: .value) { userSnapshot in
                    var email = "", name = "", username = "", number = ""
                    if let userDict = userSnapshot.value as? [String: Any] {
                        email = userDict["email"] as? String ?? ""
                        name = userDict["name"] as? String ?? ""
                        username = userDict["username"] as? String ?? ""
                        number = userDict["number"] as? String ?? ""
                    } else {
                        print("Error: Unable to fetch user data for userID: \(userID)")
                    }
                    
                    let ride2 = Ride2(id: snapshot.key, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: donationRequested, userEmail: email, userName: name, userUsername: username, userNumber: number, additionalInfo: additionalInfo)
                    newRides2.append(ride2)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.rides2 = newRides2.sorted { $0.date + $0.time > $1.date + $1.time }
                self.isLoading2 = false
                print("Fetched \(newRides2.count) rides.")
            }
        }
    }
}

private func configureNavigationBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // This color adapts to light/dark mode
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
}

struct RideCell2: View {
    var ride2: Ride2
    var width: CGFloat
    var height: CGFloat
    var onDelete: (Ride2) -> Void
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.blue)
                    Text("\(ride2.fromLocation) to \(ride2.toLocation)")
                        .font(.headline)
                        .foregroundColor(.darkBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Date: \(ride2.date)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text("Time: \(ride2.time)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.secondary)
                    Text("\(ride2.seats) seats - Donation: \(ride2.donationRequested)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("Posted by: \(ride2.userUsername ?? "Unknown")")
                    .font(.footnote)
                    .foregroundColor(.darkBlue)
                    .padding(.top, 2)
            }
            .padding()
            
            if ride2.userID == Auth.auth().currentUser?.uid {
                VStack {
                    HStack {
                        Spacer() // Spacer to push the button to the right
                        
                        // Edit button at the top
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        NavigationLink(destination: EditRequest(ride2: Binding.constant(ride2), rideType: .request), isActive: $isEditing) { EmptyView() }
                    }
                    
                    Spacer() // Spacer to push delete button to the bottom
                    
                    HStack {
                        Spacer() // Spacer to push the button to the right
                        
                        // Delete button at the bottom
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding() // Padding for the overall VStack
            }
        }
        .frame(width: 400, height: 200, alignment: .leading)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Confirm Delete"),
                message: Text("Are you sure you want to delete this ride?"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete(ride2)
                },
                secondaryButton: .cancel()
            )
        }
    }
}




struct RideCellSkeleton2: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.85, green: 0.85, blue: 0.85)) // Custom light gray color
                .shadow(radius: 5)
            
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(width: 30, height: 30)
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(height: 20)
                }
                
                Divider()
                
                ForEach(0..<3) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(width: 20, height: 20)
                        Rectangle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(height: 20)
                    }
                }
            }
            .padding()
        }
        .frame(width: 400, height: 200, alignment: .leading)
    }
}

struct Request_Previews: PreviewProvider {
    static var previews: some View {
        Request()
    }
}
