//
//  MainView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI
import GooglePlaces
import CoreLocation

struct MainView: View {
    @State private var showingStartLocationPrompt = false
    @State private var showingEndLocationPrompt = false
    @State private var startLocation: String = ""
    @State private var endLocation: String = ""
    @State private var stops: [String] = []
    @State private var startLocationForRouting: String = ""
    @State private var endLocationForRouting: String = ""
    @State private var stopsForRouting: [String] = []
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
    @State private var encodedPolyline: String? = nil
    @State private var startCoordinate: CLLocationCoordinate2D?
    @State private var endCoordinate: CLLocationCoordinate2D?
    @State private var stopsCoordinates: [CLLocationCoordinate2D?] = []

    private var mapPins: [MapPinData] {
        var pins = [MapPinData]()

        if let startCoord = startCoordinate, !startLocation.isEmpty {
            pins.append(MapPinData(coordinate: startCoord, title: startLocation))
        }

        for (index, stopName) in stops.enumerated() {
            if stopsCoordinates.indices.contains(index),
               let coord = stopsCoordinates[index],
               !stopName.isEmpty
            {
                pins.append(MapPinData(coordinate: coord, title: stopName))
            }
        }

        if let endCoord = endCoordinate, !endLocation.isEmpty {
            pins.append(MapPinData(coordinate: endCoord, title: endLocation))
        }

        return pins
    }

    // just resets everything back to default
    func resetEstimator() {
        startLocation = ""
        endLocation = ""
        stops = []
        startLocationForRouting = ""
        endLocationForRouting = ""
        stopsForRouting = []
        travelTime = ""
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
    
    // MARK: - Change Button Text
    func changeText() {
        switch stopCounter {
        case 0:
            addText = "Add Stops?"
        case 1:
            addText = "Another?"
        case 2:
            addText = "Even More?"
        case 3:
            addText = "Why not walk?"
        case 4:
            addText = "Buy a car at this point."
        default:
            addText = "Alright Go Crazy." // fallback
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color
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

                            // Menu
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
                                // Start Location
                                Button(action: {
                                    isStartLocation = true
                                    isPresentingAutocomplete = true
                                }) {
                                    Text(startLocation.isEmpty ? "Start Location" : startLocation)
                                        .padding()
                                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                        .frame(maxWidth: geometry.size.width * 0.8)
                                        .background(Color.theme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(geometry.size.width * 0.05)
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                }

                                // Stops
                                ForEach(stops.indices, id: \.self) { index in
                                    HStack(spacing: geometry.size.width * 0.02) {
                                        Button(action: {
                                            stops.remove(at: index)
                                            stopsForRouting.remove(at: index)
                                            stopsCoordinates.remove(at: index) // remove coordinate
                                            stopCounter -= 1
                                            changeText()
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.05)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Button(action: {
                                            isStartLocation = false
                                            currentStopIndex = index
                                            isPresentingAutocomplete = true
                                        }) {
                                            Text(stops[index].isEmpty ? "Stop #\(index + 1)" : stops[index])
                                                .padding()
                                                .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                                .frame(maxWidth: geometry.size.width * 0.7)
                                                .background(Color.theme.accent)
                                                .foregroundColor(.white)
                                                .cornerRadius(geometry.size.width * 0.05)
                                                .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                        }
                                        .padding(.trailing, geometry.size.width * 0.1)
                                    }
                                }

                                // Add Stop
                                Button(action: {
                                    stops.append("")
                                    stopsForRouting.append("")
                                    stopsCoordinates.append(nil) // track coordinate
                                    stopCounter += 1
                                    changeText()
                                }) {
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

                                // End Location
                                Button(action: {
                                    isStartLocation = false
                                    currentStopIndex = nil
                                    isPresentingAutocomplete = true
                                }) {
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

                                // Get Estimate
                                Button(action: {
                                    errorOccurred = false
                                    
                                    estimateTripTime(
                                        startAddress: startLocationForRouting,
                                        endAddress: endLocationForRouting,
                                        waypoints: stopsForRouting
                                    ) { timeText, timeValue, polyline in
                                        // Check error
                                        if timeText.lowercased().contains("error") || timeValue == 0 {
                                            errorOccurred = true
                                            travelTime = ""
                                            travelTimeValue = 0.0
                                            tripCost = 0.0
                                            encodedPolyline = nil
                                        } else {
                                            travelTime = timeText
                                            travelTimeValue = timeValue
                                            calculateCost(travelCost: timeValue) { cost in
                                                tripCost = cost
                                            }
                                            encodedPolyline = polyline
                                        }
                                    }
                                    withAnimation(.easeInOut(duration: 1.2)) {
                                        estimateAnimation = true
                                    }
                                }) {
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

                            // this is what displays the map (if the polyline is valid that is)
                            if let validPolyline = encodedPolyline,
                               !validPolyline.isEmpty,
                               !errorOccurred
                            {
                                RouteMapView(
                                    encodedPolyline: validPolyline,
                                    pins: mapPins
                                )
                                .frame(
                                    width: geometry.size.width * 0.8,
                                    height: geometry.size.height * 0.3
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                )
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
                        startCoordinate: $startCoordinate,
                        endCoordinate: $endCoordinate,
                        stopsCoordinates: $stopsCoordinates
                    )
                }
            }
        }
    }
}

#Preview {
    MainView()
}
