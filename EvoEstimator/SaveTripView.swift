//
//  SaveTripView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import SwiftUI
import CoreLocation

struct SaveTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tripStorage: TripStorage
    var currentDisplayStart: String
    var currentDisplayEnd: String
    var currentDisplayStops: [String]
    var currentRoutingStart: String
    var currentRoutingEnd: String
    var currentRoutingStops: [String]
    var currentStopDurations: [Int]
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var stopsCoordinates: [CLLocationCoordinate2D?]
    
    @State private var tripName: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // save the trip if a name is provided
    private func saveTrip() {
        if tripName.isEmpty {
            alertMessage = "please enter a trip name"
            showAlert = true
            return
        }
        
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
        dismiss() // close the view after saving
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("trip name")) {
                    TextField("enter trip name", text: $tripName)
                }
                Section(header: Text("trip details")) {
                    Text("from: \(currentDisplayStart)")
                    Text("to: \(currentDisplayEnd)")
                    if !currentDisplayStops.isEmpty {
                        ForEach(currentDisplayStops.indices, id: \.self) { index in
                            Text("stop \(index + 1): \(currentDisplayStops[index])")
                        }
                    }
                }
            }
            .navigationTitle("save trip")
            .navigationBarItems(
                leading: Button("cancel") {
                    dismiss()
                },
                trailing: Button("save") {
                    saveTrip()
                }
            )
        }
    }
}
