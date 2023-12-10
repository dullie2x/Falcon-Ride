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
    @State private var showingAddView = false
    @State private var showingFilterSheet = false
    @State private var filterAvailableRides = false
    @State private var selectedDate: Date?
    
    private var currentUserID: String? = Auth.auth().currentUser?.uid
    
    
    init() {
        configureNavigationBarAppearance()
        fetchRides2()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.darkBlue)
                        TextField("Search", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.gray)
                        Button(action: { showingFilterSheet = true }) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .imageScale(.large)
                                .foregroundColor(.darkBlue)
                        }
                    }
                    .padding()
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .background(Color.white)
                    .frame(width: geometry.size.width, alignment: .leading)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if isLoading2 {
                                // RideCellSkeletons for loading state
                            } else {
                                ForEach(filteredRides2()) { ride2 in
                                    NavigationLink(destination: OtherUserProfile(rideInfo: .request(ride2), additionalInfo: ride2.additionalInfo ?? "", fromLocation: ride2.fromLocation, toLocation: ride2.toLocation, time: ride2.time, seats: ride2.seats, donationRequested: ride2.donationRequested ?? "")) {
                                        RideCell2(ride2: ride2, width: geometry.size.width - 20, height: geometry.size.width * 0.5, onDelete: { selectedRide in
                                            guard selectedRide.userID == currentUserID else { return }
                                            DataHandler.shared.deleteRide(rideId: selectedRide.id, node: "rideRequest") { error in
                                                // Handle error or success
                                            }
                                        })
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                    }
                                    .frame(width: geometry.size.width)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showingFilterSheet) {
                        FilterView(filterAvailableRides: $filterAvailableRides, selectedDate: $selectedDate)
                    }
                    
                    NavigationLink(destination: AddRequestView(), isActive: $showingAddRequestView) { EmptyView() }
                }
                .navigationBarTitle("Requests", displayMode: .automatic)
                .navigationBarItems(trailing: addButton)
                .background(Color.white)
                .onAppear(perform: fetchRides2)
            }
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
                .foregroundColor(.darkBlue)
        }
    }
    func filteredRides2() -> [Ride2] {
        rides2.filter { ride2 in
            // Filter by search text
            let matchesSearchText = searchText.isEmpty || ride2.fromLocation.lowercased().contains(searchText.lowercased()) || ride2.toLocation.lowercased().contains(searchText.lowercased())
            
            // Filter by available seats if the toggle is on
            let matchesAvailableSeats = !filterAvailableRides || (filterAvailableRides && ride2.seats != "0")
            
            // Filter by selected date
            let matchesSelectedDate = selectedDate == nil || isSameDay2(ride2.date, selectedDate!)
            
            return matchesSearchText && matchesAvailableSeats && matchesSelectedDate
        }
    }
    func isSameDay2(_ rideDate: String, _ selectedDate: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust this format based on how dates are stored in your Ride structure
        if let date = dateFormatter.date(from: rideDate) {
            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
        return false
    }
    
    // Function to fetch rides from Firebase
    func fetchRides2() {
        let currentUserID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let ridesRef = ref.child("rideRequest")
        let usersRef = ref.child("users")
        let currentDate = Date()
        
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
                
                // Date check to filter out past rides
                let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust this format based on how dates are stored in your Ride2 structure
                        if let rideDate = dateFormatter.date(from: formattedDate) {
                            let rideDatePlus24Hours = Calendar.current.date(byAdding: .day, value: 1, to: rideDate)!
                            if rideDatePlus24Hours < currentDate {
                                continue
                            }
                        } else {
                            continue
                        }
                
                group.enter()
                usersRef.child(userID).observeSingleEvent(of: .value) { userSnapshot in
                    if userSnapshot.exists() {
                        var email = "", name = "", username = "", number = ""
                        if let userDict = userSnapshot.value as? [String: Any] {
                            email = userDict["email"] as? String ?? ""
                            name = userDict["name"] as? String ?? ""
                            username = userDict["username"] as? String ?? ""
                            number = userDict["number"] as? String ?? ""
                        }
                        
                        let ride2 = Ride2(id: snapshot.key, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: donationRequested, userEmail: email, userName: name, userUsername: username, userNumber: number, additionalInfo: additionalInfo)
                        newRides2.append(ride2)
                    } else {
                        print("User not found for userID: \(userID), ride not added.")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                // Sort the rides by date and time in ascending order
                self.rides2 = newRides2.sorted { $0.date + $0.time < $1.date + $1.time }
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
        .frame(width: width, height: height, alignment: .leading)
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
