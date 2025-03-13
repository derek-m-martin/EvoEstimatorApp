//
//  SaveTripView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import SwiftUI
import CoreLocation

struct SaveTripView: View {
    @ObservedObject var tripStorage: TripStorage
    var currentDisplayStart: String
    var currentDisplayEnd: String
    var currentDisplayStops: [String]
    var currentRoutingStart: String
    var currentRoutingEnd: String
    var currentRoutingStops: [String]
    
    var currentStopDurations: [Int]
    // Add coordinate properties
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var stopsCoordinates: [CLLocationCoordinate2D?]
    
    @State private var tripName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Name")) {
                    TextField("Enter trip name", text: $tripName)
                }
                Section(header: Text("Trip Details")) {
                    Text("From: \(currentDisplayStart)")
                    Text("To: \(currentDisplayEnd)")
                    if !currentDisplayStops.isEmpty {
                        ForEach(currentDisplayStops.indices, id: \.self) { index in
                            Text("Stop \(index + 1): \(currentDisplayStops[index])")
                        }
                    }
                }
            }
            .navigationTitle("Save Trip")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !tripName.isEmpty {
                        let newTrip = Trip(
                            name: tripName,
                            displayStartLocation: currentDisplayStart,
                            routingStartLocation: currentRoutingStart,
                            displayEndLocation: currentDisplayEnd,
                            routingEndLocation: currentRoutingEnd,
                            displayStops: currentDisplayStops,
                            routingStops: currentRoutingStops,
                            stopDurations: currentStopDurations,
                            startCoordinate: startCoordinate.map { LocationCoordinate(from: $0) },
                            endCoordinate: endCoordinate.map { LocationCoordinate(from: $0) },
                            stopCoordinates: stopsCoordinates.map { $0.map { LocationCoordinate(from: $0) } }
                        )
                        tripStorage.addTrip(newTrip)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}
