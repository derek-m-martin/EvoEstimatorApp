//
//  TripStorage.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import Foundation
import SwiftUI

class TripStorage: ObservableObject {
    @Published var trips: [Trip] = []
    
    private let fileName = "savedTrips.json"
    
    private var fileURL: URL? {
        do {
            let fm = FileManager.default
            let docs = try fm.url(for: .documentDirectory,
                                  in: .userDomainMask,
                                  appropriateFor: nil,
                                  create: false)
            return docs.appendingPathComponent(fileName)
        } catch {
            print("Error getting file URL: \(error)")
            return nil
        }
    }
    
    init() {
        loadTrips()
    }
    
    func loadTrips() {
        guard let url = fileURL else { return }
        do {
            let data = try Data(contentsOf: url)
            let decodedTrips = try JSONDecoder().decode([Trip].self, from: data)
            self.trips = decodedTrips
        } catch {
            print("Error loading trips: \(error)")
            self.trips = []
        }
    }
    
    func saveTrips() {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(trips)
            try data.write(to: url)
            print("Trips saved!")
        } catch {
            print("Error saving trips: \(error)")
        }
    }
    
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }
    
    func deleteTrip(at offsets: IndexSet) {
        trips.remove(atOffsets: offsets)
        saveTrips()
    }
}
