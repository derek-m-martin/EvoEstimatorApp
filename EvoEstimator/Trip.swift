//
//  Trip.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import Foundation

struct Trip: Codable, Identifiable {
    let id: UUID
    var name: String
    var displayStartLocation: String
    var displayEndLocation: String
    var displayStops: [String]
    var routingStartLocation: String
    var routingEndLocation: String
    var routingStops: [String]
    
    var stopDurations: [Int]
    
    init(id: UUID = UUID(),
         name: String,
         displayStartLocation: String,
         routingStartLocation: String,
         displayEndLocation: String,
         routingEndLocation: String,
         displayStops: [String] = [],
         routingStops: [String] = [],
         stopDurations: [Int] = []) {
        self.id = id
        self.name = name
        self.displayStartLocation = displayStartLocation
        self.routingStartLocation = routingStartLocation
        self.displayEndLocation = displayEndLocation
        self.routingEndLocation = routingEndLocation
        self.displayStops = displayStops
        self.routingStops = routingStops
        self.stopDurations = stopDurations
    }
}
