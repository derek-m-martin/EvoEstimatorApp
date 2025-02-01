//
//  ViewHandler.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-30.
//

import Foundation
import SwiftUI
import MapKit

struct ViewHandler: View {
    @State private var showResultView = false
    @State private var fadeToBlack = false
    @State private var errorOccurred = false
    @State private var travelTime = ""
    @State private var travelTimeValue: Double = 0.0
    @State private var tripCost: Double = 0.0
    @State private var finalStopSeconds: Int = 0
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var stops: [String] = []
    @State private var startCoordinate: CLLocationCoordinate2D?
    @State private var endCoordinate: CLLocationCoordinate2D?
    @State private var stopsCoordinates: [CLLocationCoordinate2D?] = []
    @State private var primaryPolyline: String?
    @State private var alternativePolylines: [String] = []
    
    func resetEstimator() {
        errorOccurred = false
        travelTime = ""
        travelTimeValue = 0.0
        tripCost = 0.0
        finalStopSeconds = 0
        startLocation = ""
        endLocation = ""
        stops = []
        startCoordinate = nil
        endCoordinate = nil
        stopsCoordinates = []
        primaryPolyline = nil
        alternativePolylines = []
    }
    
    var body: some View {
        ZStack {
            if showResultView {
                ResultView(
                    errorOccurred: errorOccurred,
                    travelTime: travelTime,
                    travelTimeValue: travelTimeValue,
                    tripCost: tripCost,
                    finalStopSeconds: finalStopSeconds,
                    startLocation: startLocation,
                    endLocation: endLocation,
                    stops: stops,
                    routingStart: startLocation,
                    routingEnd: endLocation,
                    routingStops: stops,
                    startCoordinate: startCoordinate,
                    endCoordinate: endCoordinate,
                    stopsCoordinates: stopsCoordinates,
                    primaryPolyline: primaryPolyline,
                    showResultView: $showResultView,
                    fadeToBlack: $fadeToBlack,
                    onCloseEstimate: {
                        resetEstimator()
                    }
                )
                .transition(.opacity)
            } else {
                MainView(
                    showResultView: $showResultView,
                    fadeToBlack: $fadeToBlack,
                    errorOccurred: $errorOccurred,
                    travelTime: $travelTime,
                    travelTimeValue: $travelTimeValue,
                    tripCost: $tripCost,
                    finalStopSeconds: $finalStopSeconds,
                    startLocation: $startLocation,
                    endLocation: $endLocation,
                    stops: $stops,
                    startCoordinate: $startCoordinate,
                    endCoordinate: $endCoordinate,
                    stopsCoordinates: $stopsCoordinates,
                    primaryPolyline: $primaryPolyline,
                    alternativePolylines: $alternativePolylines
                )
                .transition(.opacity)
            }
            
            if fadeToBlack {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showResultView)
        .animation(.easeInOut(duration: 0.3), value: fadeToBlack)
    }
}

#Preview {
    ViewHandler()
}
