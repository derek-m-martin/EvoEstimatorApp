//
//  TripStorage.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import Foundation
import SwiftUI

// manages saving and loading of trip data
class TripStorage: ObservableObject {
    @Published var savedTrips: [SavedTrip] = []
    private let tripsKey = "savedTrips"
    
    init() {
        loadTrips()
    }
    
    // loads saved trips from user defaults
    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey) {
            if let decoded = try? JSONDecoder().decode([SavedTrip].self, from: data) {
                savedTrips = decoded
            }
        }
    }
    
    // saves trips to user defaults
    private func saveTrips() {
        if let encoded = try? JSONEncoder().encode(savedTrips) {
            UserDefaults.standard.set(encoded, forKey: tripsKey)
        }
    }
    
    // adds a new trip to storage
    func addTrip(_ trip: SavedTrip) {
        savedTrips.append(trip)
        saveTrips()
    }
    
    // removes a trip from storage
    func removeTrip(at offsets: IndexSet) {
        savedTrips.remove(atOffsets: offsets)
        saveTrips()
    }
}

// represents a saved trip with all its details
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
