//
//  HandleTravelTime.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-11.
//

import Foundation
import SwiftUI
import GooglePlaces
import CoreLocation

func estimateTripTime(
    startAddress: String,
    endAddress: String,
    waypoints: [String] = [],
    stoppedTime: [Int],
    completion: @escaping (String, Double, String?) -> Void
) {
    guard !startAddress.isEmpty, !endAddress.isEmpty else {
        DispatchQueue.main.async {
            completion("Missing Address Error", 0, nil)
        }
        return
    }
    
    let apiKey = APIKeys.googleAPIKey

    let originsEncoded = startAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let destinationsEncoded = endAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let waypointsEncoded = waypoints
        .map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
        .joined(separator: "%7C")
    let waypointsParam = waypointsEncoded.isEmpty ? "" : "&waypoints=\(waypointsEncoded)"
    let urlString = """
    https://maps.googleapis.com/maps/api/directions/json?origin=\(originsEncoded)&destination=\(destinationsEncoded)\(waypointsParam)&mode=driving&key=\(apiKey)
    """
    guard let url = URL(string: urlString) else {
        DispatchQueue.main.async {
            completion("Invalid URL Error", 0, nil)
        }
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion("Error fetching data", 0, nil)
            }
            return
        }
        guard let data = data else {
            DispatchQueue.main.async {
                completion("No data received Error", 0, nil)
            }
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let status = json["status"] as? String, status != "OK" {
                    DispatchQueue.main.async {
                        completion("Google API Error: \(status)", 0, nil)
                    }
                    return
                }
                guard
                    let routes = json["routes"] as? [[String: Any]],
                    let firstRoute = routes.first
                else {
                    DispatchQueue.main.async {
                        completion("No routes found", 0, nil)
                    }
                    return
                }
                var encodedPolyline: String? = nil
                if let overview = firstRoute["overview_polyline"] as? [String: Any],
                   let points = overview["points"] as? String {
                    encodedPolyline = points
                }
                if let legs = firstRoute["legs"] as? [[String: Any]] {
                    var totalDurationValue: Double = 0
                    for leg in legs {
                        if let duration = leg["duration"] as? [String: Any],
                           let durationValue = duration["value"] as? Double {
                            totalDurationValue += durationValue
                        }
                    }
                    let formattedDuration = formatDuration(seconds: totalDurationValue, arr: stoppedTime)
                    DispatchQueue.main.async {
                        completion(formattedDuration, totalDurationValue, encodedPolyline)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("No routes found", 0, nil)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion("Error parsing JSON", 0, nil)
            }
        }
    }.resume()
}

func formatDuration(seconds: Double, arr: [Int]) -> String {
    let totalSeconds = Int(seconds) + (arr[0] * 86400 + arr[1] * 3600 + arr[2] * 60)
    let days = totalSeconds / 86400
    let hours = (totalSeconds % 86400) / 3600
    let minutes = (totalSeconds % 3600) / 60
    
    if days > 0 && hours > 0 && minutes > 0 {
        return "\(days) days \(hours) hours \(minutes) min"
    } else if days > 0 && hours > 0 {
        return "\(days) days \(hours) hours"
    } else if days > 0 {
        return "\(days) days"
    } else if hours > 0 && minutes > 0 {
        return "\(hours) hr \(minutes) min"
    } else if hours > 0 {
        return "\(hours) hr"
    } else {
        return "\(minutes) min"
    }
}
