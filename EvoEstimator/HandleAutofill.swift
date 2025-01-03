//
//  HandleAutofill.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-11.
//

import Foundation
import SwiftUI
import GooglePlaces
import CoreLocation

struct AutocompleteViewController: UIViewControllerRepresentable {
    @Binding var isStartLocation: Bool
    @Binding var startLocation: String
    @Binding var endLocation: String
    @Binding var stops: [String]
    @Binding var currentStopIndex: Int?
    
    // Routing strings
    @Binding var startLocationForRouting: String
    @Binding var endLocationForRouting: String
    @Binding var stopsForRouting: [String]

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        // Vancouver location bounds in lat/long
        let seBoundsCorner = CLLocationCoordinate2DMake(49.053671,-122.520286)
        let nwBoundsCorner = CLLocationCoordinate2DMake(49.385683, -123.305633)
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        
        let filter = GMSAutocompleteFilter()
        filter.countries = ["CA"]
        filter.locationBias = GMSPlaceRectangularLocationOption(nwBoundsCorner, seBoundsCorner)
        
        autocompleteController.autocompleteFilter = filter

        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isStartLocation: $isStartLocation,
            startLocation: $startLocation,
            endLocation: $endLocation,
            stops: $stops,
            currentStopIndex: $currentStopIndex,
            startLocationForRouting: $startLocationForRouting,
            endLocationForRouting: $endLocationForRouting,
            stopsForRouting: $stopsForRouting
        )
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        @Binding var isStartLocation: Bool
        @Binding var startLocation: String
        @Binding var endLocation: String
        @Binding var stops: [String]
        @Binding var currentStopIndex: Int?
        
        // Routing strings
        @Binding var startLocationForRouting: String
        @Binding var endLocationForRouting: String
        @Binding var stopsForRouting: [String]

        init(isStartLocation: Binding<Bool>,
             startLocation: Binding<String>,
             endLocation: Binding<String>,
             stops: Binding<[String]>,
             currentStopIndex: Binding<Int?>,
             startLocationForRouting: Binding<String>,
             endLocationForRouting: Binding<String>,
             stopsForRouting: Binding<[String]>) {
            
            _isStartLocation = isStartLocation
            _startLocation = startLocation
            _endLocation = endLocation
            _stops = stops
            _currentStopIndex = currentStopIndex
            _startLocationForRouting = startLocationForRouting
            _endLocationForRouting = endLocationForRouting
            _stopsForRouting = stopsForRouting
        }

        func viewController(_ viewController: GMSAutocompleteViewController,
                            didAutocompleteWith place: GMSPlace) {
            
            // Display name (short for UI)
            let displayName = place.name ?? ""
            // Full address for routing if available
            let routingAddress = place.formattedAddress ?? place.name ?? ""

            if isStartLocation {
                startLocation = displayName
                startLocationForRouting = routingAddress
            } else if let index = currentStopIndex {
                stops[index] = displayName
                stopsForRouting[index] = routingAddress
            } else {
                endLocation = displayName
                endLocationForRouting = routingAddress
            }
            
            viewController.dismiss(animated: true, completion: nil)
        }

        func viewController(_ viewController: GMSAutocompleteViewController,
                            didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
            viewController.dismiss(animated: true, completion: nil)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
