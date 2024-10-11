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

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(isStartLocation: $isStartLocation, startLocation: $startLocation, endLocation: $endLocation)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        @Binding var isStartLocation: Bool
        @Binding var startLocation: String
        @Binding var endLocation: String

        init(isStartLocation: Binding<Bool>, startLocation: Binding<String>, endLocation: Binding<String>) {
            _isStartLocation = isStartLocation
            _startLocation = startLocation
            _endLocation = endLocation
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            if isStartLocation {
                startLocation = place.name ?? ""
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
