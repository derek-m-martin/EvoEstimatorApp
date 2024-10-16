//
//  HandleAutofill.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-11.
//

// ***********************
// Handles the autofill functionality of the start/end location buttons
// ***********************

import Foundation
import SwiftUI
import GooglePlaces
import CoreLocation

struct AutocompleteViewController: UIViewControllerRepresentable {
    @Binding var isStartLocation: Bool
    @Binding var startLocation: String
    @Binding var endLocation: String
    @Binding var stops: [String]
    @Binding var currentStopIndex: Int? // Track which stop is being edited
    
    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(isStartLocation: $isStartLocation, startLocation: $startLocation, endLocation: $endLocation, stops: $stops, currentStopIndex: $currentStopIndex)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        @Binding var isStartLocation: Bool
        @Binding var startLocation: String
        @Binding var endLocation: String
        @Binding var stops: [String]
        @Binding var currentStopIndex: Int?

        init(isStartLocation: Binding<Bool>, startLocation: Binding<String>, endLocation: Binding<String>, stops: Binding<[String]>, currentStopIndex: Binding<Int?>) {
            _isStartLocation = isStartLocation
            _startLocation = startLocation
            _endLocation = endLocation
            _stops = stops
            _currentStopIndex = currentStopIndex
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            if isStartLocation {
                startLocation = place.name ?? ""
            } else if let index = currentStopIndex {
                stops[index] = place.name ?? "" // Update the correct stop
            } else {
                endLocation = place.name ?? ""
            }
            viewController.dismiss(animated: true, completion: nil)
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
            viewController.dismiss(animated: true, completion: nil)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
