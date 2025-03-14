//
//  MainView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI
import GooglePlaces
import CoreLocation
import MapKit

// main view that handles the core functionality of the app
struct MainView: View {
    @Binding var showResultView: Bool
    @Binding var fadeToBlack: Bool
    @Binding var errorOccurred: Bool
    @Binding var travelTime: String
    @Binding var travelTimeValue: Double
    @Binding var tripCost: Double
    @Binding var finalStopSeconds: Int
    @Binding var startLocation: String
    @Binding var endLocation: String
    @Binding var stops: [String]
    @Binding var startCoordinate: CLLocationCoordinate2D?
    @Binding var endCoordinate: CLLocationCoordinate2D?
    @Binding var stopsCoordinates: [CLLocationCoordinate2D?]
    @Binding var primaryPolyline: String?
    @Binding var alternativePolylines: [String]
    
    // state variables for handling route planning
    @State private var startLocationForRouting: String = ""
    @State private var endLocationForRouting: String = ""
    @State private var stopsForRouting: [String] = []
    @State private var stopDurations: [Int] = []
    @State private var isPresentingAutocomplete = false
    @State private var isStartLocation = true
    @State private var currentStopIndex: Int? = nil
    @State private var estimateAnimation = false
    @State private var addText: String = "Add Stops?"
    @State private var stopCounter: Int = 0
    @State private var showStopDurationPicker = false
    @State private var stopDurationIndex: Int? = nil
    @State private var isMapFullscreen = false
    @State private var costEstimates: [Double] = []
    @State private var showDirectionsOptions = false
    @State private var fastestTravelTimeText: String = ""
    @State private var fastestTravelDuration: Double = 0.0
    @State private var shortestTravelTimeText: String = ""
    @State private var shortestTravelDuration: Double = 0.0
    @State private var showingSaveTripView = false
    @State private var showingTripSelector = false
    @State private var showingBugReport = false
    @StateObject private var tripStorage = TripStorage()
    @StateObject private var locationManager = LocationManager()
    @State private var showLocationErrorAlert = false
    @State private var locationErrorMessage = ""

    // computed property to create map pins for all locations
    private var mapPins: [MapPinData] {
        var pins = [MapPinData]()
        if let startCoord = startCoordinate, !startLocation.isEmpty {
            pins.append(MapPinData(coordinate: startCoord, title: startLocation))
        }
        for (i, stopName) in stops.enumerated() {
            if stopsCoordinates.indices.contains(i),
               let coord = stopsCoordinates[i],
               !stopName.isEmpty {
                pins.append(MapPinData(coordinate: coord, title: stopName))
            }
        }
        if let endCoord = endCoordinate, !endLocation.isEmpty {
            pins.append(MapPinData(coordinate: endCoord, title: endLocation))
        }
        return pins
    }
    
    // resets all route planning data to initial state
    func resetEstimator() {
        startLocation = ""
        endLocation = ""
        stops = []
        startLocationForRouting = ""
        endLocationForRouting = ""
        stopsForRouting = []
        stopDurations = []
        finalStopSeconds = 0
        travelTime = ""
        travelTimeValue = 0.0
        tripCost = 0.0
        estimateAnimation = false
        addText = "Add Stops?"
        stopCounter = 0
        errorOccurred = false
        primaryPolyline = nil
        startCoordinate = nil
        endCoordinate = nil
        stopsCoordinates = []
    }
    
    // updates the add stops button text based on number of stops
    func changeText() {
        switch stopCounter {
        case 0: addText = "Add Stops?"
        case 1: addText = "Another?"
        case 2: addText = "Even More?"
        case 3: addText = "Why not walk?"
        case 4: addText = "Buy a car at this point."
        default: addText = "Alright Go Crazy."
        }
    }
    
    // calculates total duration of all stops in seconds
    var totalStopSeconds: Int {
        stopDurations.reduce(0, +)
    }
    
    // formats stop duration into readable string
    func formatStopDuration(_ totalSeconds: Int) -> String {
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        var components: [String] = []
        if days > 0 { components.append("\(days) day\(days == 1 ? "" : "s")") }
        if hours > 0 { components.append("\(hours) hour\(hours == 1 ? "" : "s")") }
        if minutes > 0 { components.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }
        if components.isEmpty { return "0 minutes" }
        return components.joined(separator: ", ")
    }
    
    // converts stop duration to array of [days, hours, minutes]
    func stopCostArray() -> [Int] {
        let days = finalStopSeconds / 86400
        let hours = (finalStopSeconds % 86400) / 3600
        let minutes = (finalStopSeconds % 3600) / 60
        return [days, hours, minutes]
    }

    // converts addresses to coordinates for saved trips
    func geocodeLoadedTrip() {
        let group = DispatchGroup()
        var errors: [String] = []
        
        startCoordinate = nil
        endCoordinate = nil
        stopsCoordinates = Array(repeating: nil, count: stopsForRouting.count)
        
        if startLocationForRouting.isEmpty { return }
        
        group.enter()
        CLGeocoder().geocodeAddressString(startLocationForRouting) { placemarks, error in
            defer { group.leave() }
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self.startCoordinate = coordinate
                }
            } else {
                errors.append("Failed to geocode start address: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        
        if !endLocationForRouting.isEmpty {
            group.enter()
            CLGeocoder().geocodeAddressString(endLocationForRouting) { placemarks, error in
                defer { group.leave() }
                if let coordinate = placemarks?.first?.location?.coordinate {
                    DispatchQueue.main.async {
                        self.endCoordinate = coordinate
                    }
                } else {
                    errors.append("Failed to geocode end address: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
        
        for (index, stop) in stopsForRouting.enumerated() {
            if !stop.isEmpty {
                group.enter()
                CLGeocoder().geocodeAddressString(stop) { placemarks, error in
                    defer { group.leave() }
                    if let coordinate = placemarks?.first?.location?.coordinate {
                        DispatchQueue.main.async {
                            if self.stopsCoordinates.indices.contains(index) {
                                self.stopsCoordinates[index] = coordinate
                            }
                        }
                    } else {
                        errors.append("Failed to geocode stop (\(stop)): \(error?.localizedDescription ?? "unknown error")")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                print("Geocoding errors occurred:")
                errors.forEach { print($0) }
            }
        }
    }
    
    // main view body
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: geometry.size.height * 0.025) {
                        HStack {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Image("icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.4)
                                    .padding(.top, geometry.size.height * 0.06)
                            }
                            Spacer()
                            Menu {
                                Button("Reset Estimator", role: .destructive) {
                                    resetEstimator()
                                }
                                NavigationLink("Evo's Current Rates", destination: RatesView())
                                NavigationLink("About the Developer/App", destination: AboutView())
                                NavigationLink("Our Privacy Policy", destination: PrivacyPolicy())
                                Divider()
                                Button("Save Route") {
                                    showingSaveTripView = true
                                }
                                Button("Saved Trips") {
                                    showingTripSelector = true
                                }
                                Divider()
                                Button("Report an Issue") {
                                    showingBugReport = true
                                }
                            } label: {
                                ZStack {
                                    Image("button_backer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.14)
                                        .opacity(0.4)
                                        .padding(.top, geometry.safeAreaInsets.top + geometry.size.height * 0.02)
                                        .padding(.trailing, geometry.size.width * 0.05)
                                    Image(systemName: "line.horizontal.3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.08)
                                        .foregroundColor(.white)
                                        .padding(.top, geometry.safeAreaInsets.top + geometry.size.height * 0.02)
                                        .padding(.trailing, geometry.size.width * 0.05)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        Spacer(minLength: 5)
                        ScrollView {
                            VStack(spacing: geometry.size.height * 0.025) {
                                Button {
                                    isStartLocation = true
                                    isPresentingAutocomplete = true
                                } label: {
                                    Text(startLocation.isEmpty ? "Start Location" : startLocation)
                                        .padding()
                                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .background(Color.theme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(geometry.size.width * 0.05)
                                        .background(
                                            RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                                .stroke(Color.darkBlue, lineWidth: 3)
                                        )
                                        .overlay(
                                            Button {
                                                locationManager.requestLocation { success, error in
                                                    if success {
                                                        locationManager.getPlacemark { displayAddress, routingAddress in
                                                            DispatchQueue.main.async {
                                                                if let display = displayAddress, let routing = routingAddress {
                                                                    startLocation = display
                                                                    startLocationForRouting = routing
                                                                    CLGeocoder().geocodeAddressString(routing) { placemarks, error in
                                                                        if let coordinate = placemarks?.first?.location?.coordinate {
                                                                            startCoordinate = coordinate
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        DispatchQueue.main.async {
                                                            showLocationErrorAlert = true
                                                            locationErrorMessage = error ?? "Could not determine your current location. Please ensure location services are enabled."
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "location.fill")
                                                    .font(.system(size: geometry.size.width * 0.04))
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            .padding(.trailing, geometry.size.width * 0.05),
                                            alignment: .trailing
                                        )
                                }
                                .alert(isPresented: $showLocationErrorAlert) {
                                    Alert(
                                        title: Text("Location Error"),
                                        message: Text(locationErrorMessage),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                .padding(.bottom, 5)
                                ForEach(stops.indices, id: \.self) { i in
                                    if stopDurations.indices.contains(i) {
                                        HStack(spacing: geometry.size.width * 0.02) {
                                            Button {
                                                stops.remove(at: i)
                                                stopsForRouting.remove(at: i)
                                                stopDurations.remove(at: i)
                                                stopsCoordinates.remove(at: i)
                                                stopCounter -= 1
                                                changeText()
                                            } label: {
                                                Image(systemName: "minus.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: geometry.size.width * 0.05)
                                                    .foregroundColor(.white)
                                            }
                                            Button {
                                                isStartLocation = false
                                                currentStopIndex = i
                                                isPresentingAutocomplete = true
                                            } label: {
                                                Text(stops[i].isEmpty ? "Stop #\(i + 1)" : stops[i])
                                                    .padding()
                                                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                                    .frame(maxWidth: geometry.size.width * 0.5)
                                                    .background(Color.theme.accent)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(geometry.size.width * 0.05)
                                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                            }
                                            if !stops[i].isEmpty && stopDurations[i] >= 0 {
                                                Button("Modify\n Duration") {
                                                    stopDurationIndex = i
                                                    showStopDurationPicker = true
                                                }
                                                .font(.system(size: geometry.size.width * 0.04))
                                                .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                                Button {
                                    stops.append("")
                                    stopsForRouting.append("")
                                    stopDurations.append(0)
                                    stopsCoordinates.append(nil)
                                    stopCounter += 1
                                    changeText()
                                } label: {
                                    HStack(spacing: geometry.size.width * 0.02) {
                                        Image("plus")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: geometry.size.width * 0.05)
                                            .foregroundColor(.white)
                                        Text(addText)
                                            .font(.system(size: geometry.size.width * 0.055, weight: .light))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, geometry.size.height * 0.0)
                                }
                                Button {
                                    isStartLocation = false
                                    currentStopIndex = nil
                                    isPresentingAutocomplete = true
                                } label: {
                                    Text(endLocation.isEmpty ? "End Location" : endLocation)
                                        .padding()
                                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .background(Color.theme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(geometry.size.width * 0.05)
                                        .background(
                                            RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                                .stroke(Color.darkBlue, lineWidth: 3)
                                        )
                                }
                                Text("All Set? Hit the Button Below!")
                                    .font(.system(size: geometry.size.width * 0.055, weight: .light))
                                    .foregroundColor(.white)
                                    .padding(.vertical, geometry.size.height * 0.01)
                                Button {
                                    primaryPolyline = nil
                                    errorOccurred = false
                                    let d = totalStopSeconds / 86400
                                    let hh = (totalStopSeconds % 86400) / 3600
                                    let mm = (totalStopSeconds % 3600) / 60
                                    finalStopSeconds = totalStopSeconds
                                    let arr = [d, hh, mm]
                                    estimateTripTime(
                                        startAddress: startLocationForRouting,
                                        endAddress: endLocationForRouting,
                                        waypoints: stopsForRouting,
                                        stoppedTime: arr
                                    ) { fastestText, fastestTime, shortestText, shortestTime, polylines in
                                        if fastestText.lowercased().contains("error") || fastestTime == 0 {
                                            errorOccurred = true
                                            travelTime = ""
                                            travelTimeValue = 0
                                            tripCost = 0
                                            primaryPolyline = nil
                                        } else {
                                            errorOccurred = false
                                            travelTime = fastestText
                                            travelTimeValue = fastestTime
                                            primaryPolyline = polylines?.first
                                            alternativePolylines = Array(polylines?.dropFirst() ?? [])
                                            calculateCost(travelCost: fastestTime, stopCost: arr) { cost in
                                                tripCost = cost
                                            }
                                            fastestTravelTimeText = fastestText
                                            fastestTravelDuration = fastestTime
                                            shortestTravelTimeText = shortestText
                                            shortestTravelDuration = shortestTime
                                        }
                                    }
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        fadeToBlack = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        showResultView = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        withAnimation(.easeInOut(duration: 1.0)) {
                                            fadeToBlack = false
                                        }
                                    }
                                } label: {
                                    Text("Get my Estimate!")
                                        .padding()
                                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .background(Color.theme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(geometry.size.width * 0.05)
                                        .background(
                                            RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                                .stroke(Color.darkBlue, lineWidth: 3)
                                        )
                                }
                                UserTipsView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 15)
                            }
                            .padding(.horizontal, geometry.size.width * 0.01)
                            Spacer(minLength: 10)
                        }
                        .fullScreenCover(isPresented: $isPresentingAutocomplete) {
                            AutocompleteViewController(
                                isStartLocation: $isStartLocation,
                                startLocation: $startLocation,
                                endLocation: $endLocation,
                                stops: $stops,
                                currentStopIndex: $currentStopIndex,
                                startLocationForRouting: $startLocationForRouting,
                                endLocationForRouting: $endLocationForRouting,
                                stopsForRouting: $stopsForRouting,
                                stopDurationIndex: $stopDurationIndex,
                                showStopDurationPicker: $showStopDurationPicker,
                                startCoordinate: $startCoordinate,
                                endCoordinate: $endCoordinate,
                                stopsCoordinates: $stopsCoordinates
                            )
                            .interactiveDismissDisabled()
                        }
                        .fullScreenCover(isPresented: $showStopDurationPicker) {
                            if let stopIndex = stopDurationIndex {
                                StopPickerView(
                                    currentStopDuration: $stopDurations[stopIndex],
                                    showOrNot: $showStopDurationPicker
                                )
                                .interactiveDismissDisabled()
                            }
                        }
                    }
                }
                if fadeToBlack {
                    Color.black
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
        }
        .sheet(isPresented: $showingSaveTripView) {
            SaveTripView(
                tripStorage: tripStorage,
                currentDisplayStart: startLocation,
                currentDisplayEnd: endLocation,
                currentDisplayStops: stops,
                currentRoutingStart: startLocationForRouting.isEmpty ? startLocation : startLocationForRouting,
                currentRoutingEnd: endLocationForRouting.isEmpty ? endLocation : endLocationForRouting,
                currentRoutingStops: stopsForRouting.isEmpty ? stops : stopsForRouting,
                currentStopDurations: stopDurations,
                startCoordinate: startCoordinate,
                endCoordinate: endCoordinate,
                stopsCoordinates: stopsCoordinates
            )
        }
        .sheet(isPresented: $showingTripSelector) {
            TripSelectorView(tripStorage: tripStorage) { selectedTrip in
                startLocation = selectedTrip.displayStartLocation
                endLocation = selectedTrip.displayEndLocation
                stops = selectedTrip.displayStops
                stopDurations = selectedTrip.stopDurations
                startLocationForRouting = selectedTrip.routingStartLocation
                endLocationForRouting = selectedTrip.routingEndLocation
                stopsForRouting = selectedTrip.routingStops
                
                // Use stored coordinates if available
                if let startCoord = selectedTrip.startCoordinate {
                    startCoordinate = startCoord.toCLLocationCoordinate2D()
                }
                if let endCoord = selectedTrip.endCoordinate {
                    endCoordinate = endCoord.toCLLocationCoordinate2D()
                }
                stopsCoordinates = selectedTrip.stopCoordinates.map { $0?.toCLLocationCoordinate2D() }
                
                // Only geocode if coordinates are missing
                if startCoordinate == nil || endCoordinate == nil || stopsCoordinates.contains(where: { $0 == nil }) {
                    geocodeLoadedTrip()
                }
            }
        }
        .sheet(isPresented: $showingBugReport) {
            BugReportView()
        }
    }
}
