
//  MainView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI
import GooglePlaces
import CoreLocation

struct MainView: View {
    @State private var startLocation: String = ""
    @State private var endLocation: String = ""
    @State private var stops: [String] = []
    @State private var startLocationForRouting: String = ""
    @State private var endLocationForRouting: String = ""
    @State private var stopsForRouting: [String] = []
    @State private var stopDurations: [Int] = []
    @State private var finalStopSeconds: Int = 0
    @State private var isPresentingAutocomplete = false
    @State private var isStartLocation = true
    @State private var currentStopIndex: Int? = nil
    @State private var estimateAnimation = false
    @State private var travelTime: String = ""
    @State private var travelTimeValue: Double = 0.0
    @State private var tripCost: Double = 0.0
    @State private var addText: String = "Add Stops?"
    @State private var stopCounter: Int = 0
    @State private var errorOccurred: Bool = false
    @State private var showStopDurationPicker = false
    @State private var stopDurationIndex: Int? = nil

    @State private var encodedPolyline: String? = nil
    @State private var startCoordinate: CLLocationCoordinate2D?
    @State private var endCoordinate: CLLocationCoordinate2D?
    @State private var stopsCoordinates: [CLLocationCoordinate2D?] = []

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
        encodedPolyline = nil
        startCoordinate = nil
        endCoordinate = nil
        stopsCoordinates = []
    }

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

    var totalStopSeconds: Int {
        stopDurations.reduce(0, +)
    }

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

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
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
                            } label: {
                                ZStack {
                                    Image("button_backer")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.14)
                                        .foregroundColor(.white)
                                        .padding(.top, geometry.safeAreaInsets.top + geometry.size.height * 0.02)
                                        .padding(.trailing, geometry.size.width * 0.05)
                                        .opacity(0.4)
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
                        Spacer(minLength: 45)
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
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                }
                                ForEach(stops.indices, id: \.self) { i in
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
                                                .frame(maxWidth: geometry.size.width * 0.7)
                                                .background(Color.theme.accent)
                                                .foregroundColor(.white)
                                                .cornerRadius(geometry.size.width * 0.05)
                                                .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                        }
                                        Button("Modify Duration") {
                                            stopDurationIndex = i
                                            showStopDurationPicker = true
                                        }
                                        .font(.system(size: geometry.size.width * 0.04))
                                        .foregroundColor(.white)
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
                                    .padding(.vertical, geometry.size.height * 0.01)
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
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                }
                                Spacer(minLength: -10)
                                Text("All Set? Hit the Button Below!")
                                    .font(.system(size: geometry.size.width * 0.055, weight: .light))
                                    .foregroundColor(.white)
                                Button {
                                    encodedPolyline = nil
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
                                    ) { timeText, timeValue, polyline in
                                        if timeText.lowercased().contains("error") || timeValue == 0 {
                                            errorOccurred = true
                                            travelTime = ""
                                            travelTimeValue = 0
                                            tripCost = 0
                                            encodedPolyline = nil
                                        } else {
                                            errorOccurred = false
                                            travelTime = timeText
                                            travelTimeValue = timeValue
                                            calculateCost(travelCost: timeValue, stopCost: arr) { cost in
                                                tripCost = cost
                                            }
                                            encodedPolyline = polyline
                                        }
                                    }
                                    withAnimation(.easeInOut(duration: 1.2)) {
                                        estimateAnimation = true
                                    }
                                } label: {
                                    Text("Get my Estimate!")
                                        .padding()
                                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .background(Color.theme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(geometry.size.width * 0.05)
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                }
                                .padding(.top, geometry.size.height * 0.015)
                            }
                            .padding(.horizontal, geometry.size.width * 0.1)
                            Spacer(minLength: 65)
                            ZStack {
                                HStack {
                                    Image("speed_lines")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.4)
                                        .offset(x: estimateAnimation ? geometry.size.width : 0)
                                        .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                    Image(systemName: "car.side")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.45)
                                        .offset(x: estimateAnimation ? geometry.size.width : 0)
                                        .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                }
                                if errorOccurred {
                                    Text("An Error Has Occurred")
                                        .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                                        .foregroundColor(.red)
                                        .offset(x: estimateAnimation ? 0 : -geometry.size.width)
                                        .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                } else {
                                    VStack(spacing: geometry.size.height * 0.01) {
                                        Text("Estimated Travel Time: \(travelTime)")
                                            .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                            .foregroundColor(Color.theme.accent)
                                            .offset(x: estimateAnimation ? 0 : -geometry.size.width)
                                            .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                        Text("Estimated Stop Duration: \(formatStopDuration(finalStopSeconds))")
                                            .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                            .foregroundColor(Color.theme.accent)
                                            .offset(x: estimateAnimation ? 0 : -geometry.size.width)
                                            .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                        Text("Estimated Trip Price: $\(String(format: "%.2f", tripCost))")
                                            .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                            .foregroundColor(Color.theme.accent)
                                            .offset(x: estimateAnimation ? 0 : -geometry.size.width)
                                            .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                    }
                                }
                            }
                            .padding(.bottom, geometry.size.height * 0.03)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
                            if let validPolyline = encodedPolyline,
                               !validPolyline.isEmpty,
                               !errorOccurred {
                                RouteMapView(
                                    encodedPolyline: validPolyline,
                                    pins: mapPins
                                )
                                .frame(
                                    width: geometry.size.width * 0.8,
                                    height: geometry.size.height * 0.3
                                )
                                .clipShape(RoundedRectangle(cornerRadius: geometry.size.width * 0.05))
                                .shadow(
                                    color: Color.theme.accent.opacity(1),
                                    radius: 5,
                                    x: 0,
                                    y: 2
                                )
                                .padding(.bottom, 30)
                            }
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAutocomplete) {
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
                }
                .sheet(isPresented: $showStopDurationPicker) {
                    if let stopIndex = stopDurationIndex {
                        StopPickerView(
                            currentStopDuration: $stopDurations[stopIndex],
                            showOrNot: $showStopDurationPicker
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
