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
    @State var isPresentingAutocomplete = false
    @State var isStartLocation = true
    @State var estimateAnimation = false
    @State var travelTime: String = ""
    @State var travelTimeValue: Double = 0.0
    @State var tripCost: Double = 0.0

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
                                    startLocation = ""
                                    endLocation = ""
                                    travelTime = ""
                                    tripCost = 0.0
                                    estimateAnimation = false
                                }

                                NavigationLink("Evo's Current Rates", destination: RatesView())
                                NavigationLink("About the App", destination: AboutView())
                                NavigationLink("Our Privacy Policy", destination: PrivacyPolicy())
                            } label: {
                                Image(systemName: "line.horizontal.3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.08)
                                    .foregroundColor(.white)
                                    .padding(.top, geometry.safeAreaInsets.top + geometry.size.height * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.05)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)

                        Spacer()

                        // Main Content
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
                            }

                            // Add Stops?
                            Button(action: {
                                // Implement add stops functionality here
                            }) {
                                HStack(spacing: geometry.size.width * 0.02) {
                                    Image("plus")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.05)
                                        .foregroundColor(.white)

                                    Text("Add Stops?")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .shadow(
                                            color: Color.theme.accent.opacity(1),
                                            radius: 1,
                                                x: -2,
                                                y: 2
                                            )
                                }
                                .padding(.vertical, geometry.size.height * 0.01)
                            }

                            // End Location Button
                            Button(action: {
                                isStartLocation = false
                                isPresentingAutocomplete = true
                            }) {
                                Text(endLocation.isEmpty ? "End Location" : endLocation)
                                    .padding()
                                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                    .frame(maxWidth: geometry.size.width * 0.8)
                                    .background(Color.theme.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(geometry.size.width * 0.05)
                            }

                            // Get Estimate Button
                            Button(action: {
                                estimateTripTime(startAddress: startLocation, endAddress: endLocation) { timeText, timeValue in
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
                            }
                            .padding(.top, geometry.size.height * 0.015)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)

                        Spacer()

                        // Car/Speed Lines and Estimated Info in ZStack
                        ZStack {
                            // Car and Speed Lines Images
                            HStack {
                                // Speed Lines Image
                                Image("speed_lines")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.3)
                                    .offset(x: estimateAnimation ? geometry.size.width : 0)
                                    .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                    .shadow(
                                        color: Color.theme.accent.opacity(1),
                                        radius: 1.2,
                                            x: -2,
                                            y: 2
                                        )

                                // Car Skeleton Image
                                Image("car-skeleton")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.4)
                                    .offset(x: estimateAnimation ? geometry.size.width : 0)
                                    .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
                                    .shadow(
                                        color: Color.theme.accent.opacity(0.5),
                                        radius: 1.2,
                                            x: -2,
                                            y: 2
                                        )
                            }

                            // Estimated Travel Time and Price
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
                .sheet(isPresented: $isPresentingAutocomplete) {
                    AutocompleteViewController(isStartLocation: $isStartLocation, startLocation: $startLocation, endLocation: $endLocation)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
