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
    @State var showingStartLocationPrompt = false
    @State var showingEndLocationPrompt = false
    @State var startLocation: String = ""
    @State var endLocation: String = ""
    @State var stops: [String] = []
    @State var isPresentingAutocomplete = false
    @State var isStartLocation = true
    @State var currentStopIndex: Int? = nil
    @State var estimateAnimation = false
    @State var travelTime: String = ""
    @State var travelTimeValue: Double = 0.0
    @State var tripCost: Double = 0.0
    @State var addText: String = "Add Stops?"
    @State var stopCounter: Int = 0

    func resetEstimator() {
        startLocation = ""
        endLocation = ""
        stops = []
        travelTime = ""
        tripCost = 0.0
        estimateAnimation = false
        addText = "Add Stops?"
    }
    
    func changeText() {
        if stopCounter == 0 {
            addText = "Add Stops?"
        }
        else if stopCounter == 1 {
            addText = "Another?"
        }
        else if stopCounter == 2 {
            addText = "Even More?"
        }
        else if stopCounter == 3 {
            addText = "Why not walk?"
        }
        else if stopCounter == 4 {
            addText = "Buy a car at this point."
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color
                    Color.black.ignoresSafeArea()

                    VStack {
                        // Title and Reset Button
                        HStack {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Image("icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.4)
                                    .padding(.top, geometry.size.height * 0.06)
                            }

                            Spacer()

                            // Dropdown menu!
                            Menu {
                                Button("Reset Estimator", role: .destructive) {
                                    resetEstimator()
                                }
                                NavigationLink("Evo's Current Rates", destination: RatesView())
                                NavigationLink("About the App", destination: AboutView())
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
                                // Start Location Button
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

                                // Stops Buttons
                                ForEach(stops.indices, id: \.self) { index in
                                    HStack(spacing: geometry.size.width * 0.02) {
                                        
                                        Button(action: {
                                            stops.remove(at: index)
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

                                // Add Stops Button
                                Button(action: {
                                    stops.append("")
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

                                // End Location Button
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

                                // Get Estimate Button
                                Button(action: {
                                    estimateTripTime(startAddress: startLocation, endAddress: endLocation, waypoints: stops) { timeText, timeValue in
                                        travelTime = timeText
                                        travelTimeValue = timeValue
                                        calculateCost(travelCost: timeValue) { cost in
                                            tripCost = cost
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
                            .padding(.bottom, geometry.size.height * 0.09)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.2)
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAutocomplete) {
                    AutocompleteViewController(isStartLocation: $isStartLocation, startLocation: $startLocation, endLocation: $endLocation, stops: $stops, currentStopIndex: $currentStopIndex)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
