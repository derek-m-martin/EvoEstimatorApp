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
    @Binding var stopDurationIndex: Int?
    @Binding var showStopDurationPicker: Bool

    @Binding var startCoordinate: CLLocationCoordinate2D?
    @Binding var endCoordinate: CLLocationCoordinate2D?
    @Binding var stopsCoordinates: [CLLocationCoordinate2D?]

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator // set our delegate
        let filter = GMSAutocompleteFilter()
        filter.countries = ["CA"] // restrict to canada
        autocompleteController.autocompleteFilter = filter
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {
        // no update logic needed here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        var parent: AutocompleteViewController
        init(_ parent: AutocompleteViewController) {
            self.parent = parent
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
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
                parent.stopsCoordinates[index] = coordinate
                parent.stopDurationIndex = index
                parent.showStopDurationPicker = true
            } else {
                parent.endLocation = displayName
                parent.endLocationForRouting = routingAddress
                parent.endCoordinate = coordinate
            }
            viewController.dismiss(animated: true) // close the autocomplete
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            viewController.dismiss(animated: true) // dismiss on error
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            viewController.dismiss(animated: true) // dismiss if cancelled
        }
    }
}
