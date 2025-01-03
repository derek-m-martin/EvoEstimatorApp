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
    @Binding var startLocationForRouting: String
    @Binding var endLocationForRouting: String
    @Binding var stopsForRouting: [String]
    @Binding var startCoordinate: CLLocationCoordinate2D?
    @Binding var endCoordinate: CLLocationCoordinate2D?
    @Binding var stopsCoordinates: [CLLocationCoordinate2D?]

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        // vancouvers lat/long for location biasing
        let seBoundsCorner = CLLocationCoordinate2DMake(49.053671, -122.520286)
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
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        var parent: AutocompleteViewController

        init(_ parent: AutocompleteViewController) {
            self.parent = parent
        }

        func viewController(_ viewController: GMSAutocompleteViewController,
                            didAutocompleteWith place: GMSPlace) {

            let displayName = place.name ?? ""
            let routingAddress = place.formattedAddress ?? place.name ?? ""
            let coordinate = place.coordinate

            if parent.isStartLocation {
                parent.startLocation = displayName
                parent.startLocationForRouting = routingAddress
                parent.startCoordinate = coordinate

            } else if let index = parent.currentStopIndex {
                parent.stops[index] = displayName
                parent.stopsForRouting[index] = routingAddress
                if parent.stopsCoordinates.indices.contains(index) {
                    parent.stopsCoordinates[index] = coordinate
                }

            } else {
                parent.endLocation = displayName
                parent.endLocationForRouting = routingAddress
                parent.endCoordinate = coordinate
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
