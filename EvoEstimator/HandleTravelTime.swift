//
//  HandleTravelTime.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-11.
//

// ***********************
// Handles the call to the google routes api in order to get the travel time
// ***********************

import Foundation
import SwiftUI
import GooglePlaces
import CoreLocation

import Foundation
import SwiftUI
import GooglePlaces
import CoreLocation

func estimateTripTime(startAddress: String, endAddress: String, waypoints: [String] = [], completion: @escaping (String, Double) -> Void) {
    let apiKey = APIKeys.googleAPIKey
    let originsEncoded = startAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let destinationsEncoded = endAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    // Ensure waypoints are properly encoded and joined
    let waypointsEncoded = waypoints.map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }.joined(separator: "|")
    let waypointsParam = waypointsEncoded.isEmpty ? "" : "&waypoints=\(waypointsEncoded)"

    
    // Updated URL for Directions API
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originsEncoded)&destination=\(destinationsEncoded)\(waypointsParam)&mode=driving&key=\(apiKey)"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }

    // Make the network request
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            print("No data received")
            return
        }

        do {
            // Parse the JSON response
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Check for errors in the response
                if let status = json["status"] as? String, status != "OK" {
                    print("Google API Error: \(status)")
                    if let errorMessage = json["error_message"] as? String {
                        print("Error Message: \(errorMessage)")
                    }
                    return
                }

                // Parse the "routes" key if available
                if let routes = json["routes"] as? [[String: Any]],
                   let firstRoute = routes.first,
                   let legs = firstRoute["legs"] as? [[String: Any]] {

                    var totalDurationValue: Double = 0

                    // Iterate through all legs to sum up travel time
                    for leg in legs {
                        if let duration = leg["duration"] as? [String: Any],
                           let durationValue = duration["value"] as? Double {
                            totalDurationValue += durationValue
                        }
                    }

                    let formattedDuration = formatDuration(seconds: totalDurationValue)

                    // Return the total travel time using the completion handler
                    DispatchQueue.main.async {
                        completion(formattedDuration, totalDurationValue)
                    }
                } else {
                    print("Unexpected JSON format or missing routes/legs")
                }
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }.resume()
}

// Helper function to format duration
func formatDuration(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60

    if hours > 0 && minutes > 0 {
        return "\(hours) hr \(minutes) min"
    } else if hours > 0 {
        return "\(hours) hr"
    } else {
        return "\(minutes) min"
    }
}
