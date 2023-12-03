//
//  HomePage.swift
//  Falcon Ride
//
//  Created by Abdulmalik Ariyo on 11/14/23.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct Ride: Identifiable {
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

struct Reserve: View {
    @State private var rides = [Ride]()
    @State private var searchText = ""
    @State private var showingAddView = false
    @State private var isLoading = true
    @State private var showingFilterSheet = false
    @State private var filterAvailableRides = false
    @State private var selectedDate: Date?

    private var currentUserID: String? = Auth.auth().currentUser?.uid

    init() {
        configureNavigationBarAppearance()
        fetchRides()
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search bar and filter button
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

                ScrollView {
                    VStack(spacing: 10) {
                        if isLoading {
                            // RideCellSkeletons for loading state
                        } else {
                            ForEach(filteredRides()) { ride in
                                NavigationLink(destination: OtherUserProfile(rideInfo: .reserve(ride), additionalInfo: ride.additionalInfo ?? "")) {
                                    RideCell(ride: ride, width: 300, height: 100, onDelete: { selectedRide in
                                        guard selectedRide.userID == currentUserID else { return }
                                        DataHandler.shared.deleteRide(rideId: selectedRide.id, node: "rideReserve") { error in
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
                .sheet(isPresented: $showingFilterSheet) {
                    // Filter sheet content
                    FilterView(filterAvailableRides: $filterAvailableRides, selectedDate: $selectedDate)
                }
                
                NavigationLink(destination: AddView(), isActive: $showingAddView) { EmptyView() }
            }
            .navigationBarTitle("Rides", displayMode: .automatic)
            .navigationBarItems(trailing: addButton)
            .background(Color.white)
            .onAppear(perform: fetchRides)
        }
        .background(Color.blue)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var addButton: some View {
        Button(action: {
            showingAddView = true
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .padding()
                .foregroundColor(.darkBlue)
        }
    }

    func filteredRides() -> [Ride] {
        rides.filter { ride in
            // Filter by search text
            let matchesSearchText = searchText.isEmpty || ride.fromLocation.lowercased().contains(searchText.lowercased()) || ride.toLocation.lowercased().contains(searchText.lowercased())
            
            // Filter by available seats if the toggle is on
            let matchesAvailableSeats = !filterAvailableRides || (filterAvailableRides && ride.seats != "0")
            
            // Filter by selected date
            let matchesSelectedDate = selectedDate == nil || isSameDay(ride.date, selectedDate!)

            return matchesSearchText && matchesAvailableSeats && matchesSelectedDate
        }
    }



    func isSameDay(_ rideDate: String, _ selectedDate: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust this format based on how dates are stored in your Ride structure
        if let date = dateFormatter.date(from: rideDate) {
            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
        return false
    }

        func fetchRides() {
            let currentUserID = Auth.auth().currentUser?.uid
            let ref = Database.database().reference()
            let ridesRef = ref.child("rideReserve")
            let usersRef = ref.child("users")
            
            ridesRef.observe(.value) { snapshot in
                var newRides: [Ride] = []
                
                if snapshot.childrenCount == 0 {
                    print("No rides found in Firebase.")
                    self.isLoading = false
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
                        
                        let ride = Ride(id: snapshot.key, userID: userID, fromLocation: fromLocation, toLocation: toLocation, seats: seats, date: formattedDate, time: formattedTime, donationRequested: donationRequested, userEmail: email, userName: name, userUsername: username, userNumber: number, additionalInfo: additionalInfo)
                        newRides.append(ride)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.rides = newRides.sorted { $0.date + $0.time > $1.date + $1.time }
                    self.isLoading = false
                    print("Fetched \(newRides.count) rides.")
                }
            }
        }
    }
    func formatDate(dateString: String) -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        if let date = isoDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeZone = TimeZone.current // Convert to local time zone
            return dateFormatter.string(from: date)
        } else {
            // Fallback for different date format or non-standard format
            // You can adjust this part based on the specific format of your old dates
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // Adjust this format as needed
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
            
            if let fallbackDate = fallbackFormatter.date(from: dateString) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = TimeZone.current // Convert to local time zone
                return dateFormatter.string(from: fallbackDate)
            }
        }
        return dateString // Return original string if parsing fails
    }
    
    
    func formatTime(timeString: String) -> String {
        return timeString
    }
    
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // This color adapts to light/dark mode
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    struct RideCell: View {
        var ride: Ride
        var width: CGFloat
        var height: CGFloat
        var onDelete: (Ride) -> Void
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
                        Text("\(ride.fromLocation) to \(ride.toLocation)")
                            .font(.headline)
                            .foregroundColor(.darkBlue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Date: \(ride.date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("Time: \(ride.time)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.secondary)
                        Text("\(ride.seats) seats - Donation: \(ride.donationRequested)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text("Posted by: \(ride.userUsername ?? "Unknown")")
                        .font(.footnote)
                        .foregroundColor(.darkBlue)
                        .padding(.top, 2)
                }
                .padding()
                
                if ride.userID == Auth.auth().currentUser?.uid {
                    VStack {
                        HStack {
                            Spacer() // Use Spacer to push the buttons to the right
                            
                            // Edit button at the top
                            Button(action: { isEditing = true }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            NavigationLink(destination: EditReserve(ride: Binding.constant(ride), rideType: .reserve), isActive: $isEditing) { EmptyView() }
                        }
                        
                        Spacer() // Spacer to push delete button to the bottom
                        
                        HStack {
                            Spacer() // Use Spacer to push the button to the right
                            
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
                        onDelete(ride)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    
    
    struct RideCellSkeleton: View {
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
struct FilterView: View {
    @Binding var filterAvailableRides: Bool
    @Binding var selectedDate: Date?

    var body: some View {
        VStack(spacing: 20) { // Increased spacing for better separation of elements
            Text("Filter Rides")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top) // Padding at the top for spacing

            Toggle(isOn: $filterAvailableRides) {
                Text("Show Available Rides Only")
                    .font(.headline)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue)) // Switch style toggle for a more standard look
            .padding(.horizontal) // Horizontal padding for alignment

            DatePicker("Select Date", selection: Binding(get: { selectedDate ?? Date() }, set: { selectedDate = $0 }), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle()) // Graphical style for a more user-friendly interface
                .padding(.horizontal) // Horizontal padding for alignment

            HStack {
                Button(action: {
                    filterAvailableRides = false
                    selectedDate = nil
                }) {
                    Text("Clear Filters")
                        .fontWeight(.semibold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal) // Horizontal padding for alignment
        }
        .padding() // Padding around the entire VStack
        .background(Color(.systemBackground)) // Background color for the view
        .cornerRadius(12) // Rounded corners for the view
    }
}


struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.blue : Color.gray)
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                .animation(.easeInOut, value: configuration.isOn)
        }
        .padding()
    }
}

struct DatePickerSection: View {
    @Binding var selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Date")
                .font(.headline)
                .padding(.bottom, 5)

            DatePicker("", selection: Binding(get: { selectedDate ?? Date() }, set: { selectedDate = $0 }), displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .padding()
        }
    }
}


    struct Reserve_Previews: PreviewProvider {
        static var previews: some View {
            Reserve()
        }
    }
