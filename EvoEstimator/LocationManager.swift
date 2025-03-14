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
    func requestLocation(completion: @escaping (Bool, String?) -> Void) {
        locationCompletion = completion
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            completion(false, "Location access is restricted or denied. Please enable it in Settings.")
        @unknown default:
            completion(false, "Unknown location authorization status")
        }
    }
    
    // handles successful location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationCompletion?(true, nil)
    }
    
    // handles location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                // Only show error if permission was previously granted
                if locationManager.authorizationStatus != .notDetermined {
                    locationCompletion?(false, "Location access was denied. Please enable it in Settings.")
                }
            case .locationUnknown:
                locationCompletion?(false, "Unable to determine your location. Please try again.")
            default:
                locationCompletion?(false, error.localizedDescription)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Only show error if permission was previously granted
            if status != .notDetermined {
                locationCompletion?(false, "Location access is restricted or denied. Please enable it in Settings.")
            }
        default:
            break
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
