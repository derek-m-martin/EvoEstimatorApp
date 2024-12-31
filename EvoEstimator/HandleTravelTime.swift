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

func estimateTripTime(
    startAddress: String,
    endAddress: String,
    waypoints: [String] = [],
    completion: @escaping (String, Double) -> Void
) {
    // Basic validation to avoid empty addresses
    guard !startAddress.isEmpty, !endAddress.isEmpty else {
        DispatchQueue.main.async {
            completion("Missing start/end addresses", 0)
        }
        return
    }
    
    let apiKey = APIKeys.googleAPIKey

    // Encode addresses
    let originsEncoded = startAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let destinationsEncoded = endAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    // Encode any waypoints
    let waypointsEncoded = waypoints
        .map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
        .joined(separator: "%7C")
    
    let waypointsParam = waypointsEncoded.isEmpty ? "" : "&waypoints=\(waypointsEncoded)"

    // Construct URL for Google Directions
    let urlString = """
    https://maps.googleapis.com/maps/api/directions/json?origin=\(originsEncoded)&destination=\(destinationsEncoded)\(waypointsParam)&mode=driving&key=\(apiKey)
    """
    print("Generated URL: \(urlString)")

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        DispatchQueue.main.async {
            completion("Invalid URL", 0)
        }
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion("Error fetching data", 0)
            }
            return
        }

        guard let data = data else {
            print("No data received")
            DispatchQueue.main.async {
                completion("No data received", 0)
            }
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("API Response: \(json)")
                
                // Check status from Google
                if let status = json["status"] as? String, status != "OK" {
                    print("Google API Error: \(status)")
                    if let errorMessage = json["error_message"] as? String {
                        print("Error Message: \(errorMessage)")
                    }
                    DispatchQueue.main.async {
                        completion("Google API Error: \(status)", 0)
                    }
                    return
                }

                // Parse route legs for total duration
                if let routes = json["routes"] as? [[String: Any]],
                   let firstRoute = routes.first,
                   let legs = firstRoute["legs"] as? [[String: Any]] {
                    
                    var totalDurationValue: Double = 0
                    for leg in legs {
                        guard
                            let duration = leg["duration"] as? [String: Any],
                            let durationValue = duration["value"] as? Double
                        else {
                            print("Missing duration for leg: \(leg)")
                            continue
                        }
                        totalDurationValue += durationValue
                    }

                    let formattedDuration = formatDuration(seconds: totalDurationValue)
                    DispatchQueue.main.async {
                        completion(formattedDuration, totalDurationValue)
                    }
                } else {
                    print("Unexpected JSON format or missing routes/legs")
                    DispatchQueue.main.async {
                        completion("No routes found", 0)
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion("Error parsing JSON", 0)
            }
        }
    }.resume()
}

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
