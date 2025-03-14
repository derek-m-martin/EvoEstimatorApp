//
//  LocationManager.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-13.
//

import Foundation
import CoreLocation
import GooglePlaces

// manages location services and permissions
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationError: Error?
    
    private var locationCompletion: ((Bool, String?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // requests location permission from user
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // handles successful location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    // handles location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else if status == .denied || status == .restricted {
            locationCompletion?(false, "Location access is restricted or denied. Please enable it in Settings.")
            locationCompletion = nil
        }
    }
    
    func getPlacemark(completion: @escaping (String?, String?) -> Void) {
        guard let location = self.location else {
            completion(nil, nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, nil)
                return
            }
            
            // Format for display (shorter version)
            let displayAddress = [
                placemark.subThoroughfare,
                placemark.thoroughfare,
                placemark.locality
            ].compactMap { $0 }.joined(separator: " ")
            
            // Format for routing (full address)
            let routingAddress = [
                placemark.subThoroughfare,
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode,
                placemark.country
            ].compactMap { $0 }.joined(separator: " ")
            
            completion(displayAddress, routingAddress)
        }
    }
}
