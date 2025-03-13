//
//  Trip.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import Foundation
import CoreLocation

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

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
    
    // Add coordinate storage
    var startCoordinate: LocationCoordinate?
    var endCoordinate: LocationCoordinate?
    var stopCoordinates: [LocationCoordinate?]
    
    init(id: UUID = UUID(),
         name: String,
         displayStartLocation: String,
         routingStartLocation: String,
         displayEndLocation: String,
         routingEndLocation: String,
         displayStops: [String] = [],
         routingStops: [String] = [],
         stopDurations: [Int] = [],
         startCoordinate: LocationCoordinate? = nil,
         endCoordinate: LocationCoordinate? = nil,
         stopCoordinates: [LocationCoordinate?] = []) {
        self.id = id
        self.name = name
        self.displayStartLocation = displayStartLocation
        self.routingStartLocation = routingStartLocation
        self.displayEndLocation = displayEndLocation
        self.routingEndLocation = routingEndLocation
        self.displayStops = displayStops
        self.routingStops = routingStops
        self.stopDurations = stopDurations
        self.startCoordinate = startCoordinate
        self.endCoordinate = endCoordinate
        self.stopCoordinates = stopCoordinates
    }
}
