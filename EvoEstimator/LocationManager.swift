//
//  LocationManager.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-13.
//

import Foundation
import CoreLocation
import GooglePlaces

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationError: Error?
    
    private var locationCompletion: ((Bool, String?) -> Void)?
    private var pendingEvoFetch: (([EvoCar]?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // use best accuracy
    }
    
    func fetchNearbyEvos(completion: @escaping ([EvoCar]?) -> Void) {
        print("starting evo fetch...")
        if currentLocation == nil {
            print("no location yet, requesting location...")
            requestLocation { success, error in
                if success {
                    print("location obtained, fetching evos...")
                    self.performEvoFetch(completion: completion)
                } else {
                    print("location error: \(error ?? "unknown error")")
                    completion(nil)
                }
            }
        } else {
            print("using existing location for fetch...")
            performEvoFetch(completion: completion)
        }
    }
    
    private func performEvoFetch(completion: @escaping ([EvoCar]?) -> Void) {
        guard let location = currentLocation else {
            print("no location available for evo fetch")
            completion(nil)
            return
        }
        print("fetching evos at: \(location.coordinate)")
        EvoAPIService.shared.fetchEvoCarsWithDynamicToken(
            latitude: location.coordinate.latitude, //49.272251, (vancouver location hardcode for taking app store screenshots using the simulator)
            longitude: location.coordinate.longitude //-123.132973
        ) { cars in
            if let cars = cars {
                print("fetched \(cars.count) evos")
            } else {
                print("failed to fetch evos")
            }
            completion(cars)
        }
    }
    
    func requestLocation(completion: @escaping (Bool, String?) -> Void) {
        print("requesting location authorization...")
        locationCompletion = completion
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("auth status not determined, requesting...")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("location access restricted/denied")
            completion(false, "location access denied. please enable it in settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("location authorized, requesting current location...")
            locationManager.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                if self?.currentLocation == nil {
                    print("location request timed out")
                    completion(false, "could not determine your location. please try again.")
                }
            }
        @unknown default:
            completion(false, "unknown location authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated: \(locations)")
        if let location = locations.last {
            print("setting current location: \(location)")
            currentLocation = location
            locationCompletion?(true, nil)
            locationCompletion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error: \(error.localizedDescription)")
        locationError = error
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                if locationManager.authorizationStatus != .notDetermined {
                    locationCompletion?(false, "location access was denied. please check settings.")
                }
            case .locationUnknown:
                locationCompletion?(false, "unable to get location. please try again.")
            default:
                locationCompletion?(false, error.localizedDescription)
            }
        }
        locationManager.stopUpdatingLocation()
        locationCompletion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("authorization changed to: \(manager.authorizationStatus.rawValue)")
    }
    
    func getPlacemark(completion: @escaping (String?, String?) -> Void) {
        guard let location = currentLocation else {
            print("no location available for geocoding")
            completion(nil, nil)
            return
        }
        print("reverse geocoding location: \(location.coordinate)")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("geocoding error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            guard let placemark = placemarks?.first else {
                print("no placemark found")
                completion(nil, nil)
                return
            }
            let displayAddress = self.formatDisplayAddress(from: placemark)
            let routingAddress = self.formatRoutingAddress(from: placemark)
            print("got address: \(displayAddress ?? "nil")")
            completion(displayAddress, routingAddress)
        }
    }
    
    private func formatDisplayAddress(from placemark: CLPlacemark) -> String? {
        let displayAddress = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality
        ].compactMap { $0 }.joined(separator: " ")
        return displayAddress
    }
    
    private func formatRoutingAddress(from placemark: CLPlacemark) -> String? {
        let routingAddress = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode,
            placemark.country
        ].compactMap { $0 }.joined(separator: " ")
        return routingAddress
    }
}
