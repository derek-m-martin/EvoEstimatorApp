//
//  TripStorage.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import Foundation
import SwiftUI

// manages saving and loading of trips
class TripStorage: ObservableObject {
    @Published var savedTrips: [SavedTrip] = []
    private let tripsKey = "savedTrips"
    
    init() {
        loadTrips()
    }
    
    // load trips from userdefaults
    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey) {
            if let decoded = try? JSONDecoder().decode([SavedTrip].self, from: data) {
                savedTrips = decoded
            }
        }
    }
    
    // save trips to userdefaults
    private func saveTrips() {
        if let encoded = try? JSONEncoder().encode(savedTrips) {
            UserDefaults.standard.set(encoded, forKey: tripsKey)
        }
    }
    
    // add a new trip and persist it
    func addTrip(_ trip: Trip) {
        let savedTrip = SavedTrip(
            name: trip.name,
            startLocation: trip.displayStartLocation,
            endLocation: trip.displayEndLocation,
            stops: trip.displayStops,
            stopDurations: trip.stopDurations
        )
        savedTrips.append(savedTrip)
        saveTrips()
    }
    
    // remove a trip from storage
    func removeTrip(at offsets: IndexSet) {
        savedTrips.remove(atOffsets: offsets)
        saveTrips()
    }
}

// represents a saved trip
struct SavedTrip: Codable, Identifiable {
    let id: UUID
    let name: String
    let startLocation: String
    let endLocation: String
    let stops: [String]
    let stopDurations: [Int]
    let date: Date
    
    init(name: String, startLocation: String, endLocation: String, stops: [String], stopDurations: [Int], date: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.stops = stops
        self.stopDurations = stopDurations
        self.date = date
    }
}
