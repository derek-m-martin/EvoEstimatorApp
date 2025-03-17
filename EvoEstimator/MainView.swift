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
    
    // state for route planning inputs and ui control
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
    @State private var isStartLocationExpanded = false
    @State private var evoCars: [EvoCar] = []
    @State private var showEvoMap = false
    @State private var selectedCar: EvoCar?
    @State private var selectedCarAddress: String = ""
    @State private var selectedCarDistance: Double = 0.0
    @State private var isLoadingEvos: Bool = false

    // making map pins for start, stops, end and evo cars
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
        
        for car in evoCars {
            let evoCoordinate = CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude)
            let pinTitle = "\(car.model) (\(car.plate))"
            pins.append(MapPinData(coordinate: evoCoordinate, title: pinTitle, car: car))
        }
        
        return pins
    }
    
    // clear all routing data
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
        withAnimation(.easeOut(duration: 0.3)) {
            isStartLocationExpanded = false
        }
    }
    
    // update 'add stops' button text based on count
    func changeText() {
        switch stopCounter {
        case 0: addText = "Add Stops?"
        case 1: addText = "Another?"
        case 2: addText = "Even More?"
        case 3: addText = "why not walk?"
        case 4: addText = "buy a car at this point."
        default: addText = "alright go crazy."
        }
    }
    
    // total seconds from all stops
    var totalStopSeconds: Int {
        stopDurations.reduce(0, +)
    }
    
    // make stop duration human-readable
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
    
    // split stop seconds into [days, hours, minutes]
    func stopCostArray() -> [Int] {
        let days = finalStopSeconds / 86400
        let hours = (finalStopSeconds % 86400) / 3600
        let minutes = (finalStopSeconds % 3600) / 60
        return [days, hours, minutes]
    }

    // geocode addresses for saved trips
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
                errors.append("failed to geocode start address: \(error?.localizedDescription ?? "unknown error")")
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
                    errors.append("failed to geocode end address: \(error?.localizedDescription ?? "unknown error")")
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
                        errors.append("failed to geocode stop (\(stop)): \(error?.localizedDescription ?? "unknown error")")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                print("geocoding errors:")
                errors.forEach { print($0) }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            // main ui container
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: geometry.size.height * 0.025) {
                        // header with app icon and menu
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
                        // scrollable routing options
                        ScrollView {
                            VStack(spacing: geometry.size.height * 0.025) {
                                DisclosureGroup(
                                    isExpanded: $isStartLocationExpanded,
                                    content: {
                                        VStack(spacing: 10) {
                                            Button {
                                                isStartLocation = true
                                                isPresentingAutocomplete = true
                                            } label: {
                                                HStack {
                                                    Image(systemName: "magnifyingglass")
                                                    Text("Enter Custom Location")
                                                }
                                                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.theme.accent)
                                                .cornerRadius(geometry.size.width * 0.05)
                                            }
                                            
                                            Button {
                                                locationManager.requestLocation { success, error in
                                                    if success {
                                                        locationManager.getPlacemark { displayAddress, routingAddress in
                                                            if let display = displayAddress, let routing = routingAddress {
                                                                startLocation = display
                                                                startLocationForRouting = routing
                                                                CLGeocoder().geocodeAddressString(routing) { placemarks, error in
                                                                    if let coordinate = placemarks?.first?.location?.coordinate {
                                                                        startCoordinate = coordinate
                                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                                            isStartLocationExpanded = false
                                                                        }
                                                                    }
                                                                }
                                                            } else {
                                                                showLocationErrorAlert = true
                                                                locationErrorMessage = "could not determine your current location. please try again."
                                                            }
                                                        }
                                                    } else if let errorMessage = error {
                                                        showLocationErrorAlert = true
                                                        locationErrorMessage = errorMessage
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "location.fill")
                                                    Text("Use Current Location")
                                                }
                                                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.theme.accent)
                                                .cornerRadius(geometry.size.width * 0.05)
                                            }
                                            
                                            Button {
                                                // show loading state immediately
                                                isLoadingEvos = true
                                                // then fetch nearby evos
                                                locationManager.fetchNearbyEvos { cars in
                                                    DispatchQueue.main.async {
                                                        isLoadingEvos = false
                                                        if let cars = cars, !cars.isEmpty {
                                                            evoCars = cars
                                                            showEvoMap = true
                                                        } else {
                                                            showLocationErrorAlert = true
                                                            locationErrorMessage = "no evo cars found within 1km of your location."
                                                        }
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Image(systemName: "car.fill")
                                                    Text("Find Nearby Evos")
                                                }
                                                .font(.system(size: geometry.size.width * 0.04, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(Color.theme.accent)
                                                .cornerRadius(geometry.size.width * 0.05)
                                            }
                                        }
                                        .padding(.top, 10)
                                    },
                                    label: {
                                        ZStack {
                                            HStack {
                                                Spacer()
                                                Text(startLocation.isEmpty ? "Start Location" : startLocation)
                                                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                                .accentColor(.white)
                                .padding()
                                .background(Color.theme.accent)
                                .cornerRadius(geometry.size.width * 0.05)
                                .background(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                        .stroke(Color.darkBlue, lineWidth: 3)
                                )
                                .frame(maxWidth: geometry.size.width * 0.8)
                                .alert(isPresented: $showLocationErrorAlert) {
                                    Alert(
                                        title: Text("Location Error"),
                                        message: Text(locationErrorMessage),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                                .padding(.bottom, 5)
                                // list stops with remove & modify options
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
                                // add new stop button
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
                                // set end location button
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
                                // get estimate and calculate cost
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
                        // address autocomplete sheet
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
                            .onDisappear {
                                if !startLocation.isEmpty && isStartLocation {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        isStartLocationExpanded = false
                                    }
                                }
                            }
                            .interactiveDismissDisabled()
                        }
                        // stop duration picker sheet
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
                
                if isLoadingEvos {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .blur(radius: 10)
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                LoadingPopup()
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        // save trip sheet
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
        // saved trips sheet
        .sheet(isPresented: $showingTripSelector) {
            TripSelectorView(tripStorage: tripStorage) { selectedTrip in
                startLocation = selectedTrip.startLocation
                endLocation = selectedTrip.endLocation
                stops = selectedTrip.stops
                stopDurations = selectedTrip.stopDurations
                startLocationForRouting = selectedTrip.startLocation
                endLocationForRouting = selectedTrip.endLocation
                stopsForRouting = selectedTrip.stops
                stopCounter = selectedTrip.stops.count
                changeText()
                geocodeLoadedTrip()
            }
        }
        // bug report sheet
        .sheet(isPresented: $showingBugReport) {
            BugReportView()
        }
        // evo map sheet for nearby evos
        .sheet(isPresented: $showEvoMap) {
            NavigationView {
                ZStack {
                    EvoMapView(
                        pins: mapPins,
                        selectedCar: $selectedCar,
                        selectedCarAddress: $selectedCarAddress,
                        selectedCarDistance: $selectedCarDistance,
                        userLocation: locationManager.currentLocation?.coordinate,
                        onUseForStartLocation: { address in
                            startLocation = address
                            startLocationForRouting = address
                            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                                if let coordinate = placemarks?.first?.location?.coordinate {
                                    startCoordinate = coordinate
                                }
                            }
                            showEvoMap = false
                            withAnimation(.easeOut(duration: 0.3)) {
                                isStartLocationExpanded = false
                            }
                        }
                    )
                    .onAppear {
                        print("current location when map appears: \(String(describing: locationManager.currentLocation))")
                        print("current location coord when map appears: \(String(describing: locationManager.currentLocation?.coordinate))")
                    }
                    .ignoresSafeArea()
                    
                    if !evoCars.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Text("\(evoCars.count) evo\(evoCars.count == 1 ? "" : "s") found nearby")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("within 1km of your location")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding()
                                .background(Color.theme.accent)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding(.bottom, 20)
                                Spacer()
                            }
                        }
                    }
                    
                    if let selectedCar = selectedCar {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                self.selectedCar = nil
                            }
                        
                        EvoDetailPopup(
                            car: selectedCar,
                            address: selectedCarAddress,
                            distance: selectedCarDistance,
                            onDismiss: {
                                self.selectedCar = nil
                            },
                            onUseForStartLocation: { address in
                                startLocation = address
                                startLocationForRouting = address
                                CLGeocoder().geocodeAddressString(address) { placemarks, error in
                                    if let coordinate = placemarks?.first?.location?.coordinate {
                                        startCoordinate = coordinate
                                    }
                                }
                                showEvoMap = false
                                withAnimation(.easeOut(duration: 0.3)) {
                                    isStartLocationExpanded = false
                                }
                            }
                        )
                    }
                }
                .navigationTitle("Nearby Evos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.theme.accent, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showEvoMap = false
                            withAnimation(.easeOut(duration: 0.3)) {
                                isStartLocationExpanded = false
                            }
                        }
                        .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Refresh") {
                            isLoadingEvos = true
                            locationManager.fetchNearbyEvos { cars in
                                DispatchQueue.main.async {
                                    if let cars = cars {
                                        evoCars = cars
                                    }
                                    isLoadingEvos = false
                                }
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}