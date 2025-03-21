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
    completion: @escaping (String, Double, String, Double, [String]?) -> Void
) {
    guard !startAddress.isEmpty, !endAddress.isEmpty else {
        DispatchQueue.main.async {
            completion("missing address error", 0, "missing address error", 0, nil)
        }
        return
    }
    let apiKey = APIKeys.googleAPIKey
    let originsEncoded = startAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let destinationsEncoded = endAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let waypointsEncoded = waypoints.map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }.joined(separator: "%7C")
    let waypointsParam = waypointsEncoded.isEmpty ? "" : "&waypoints=\(waypointsEncoded)"
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originsEncoded)&destination=\(destinationsEncoded)\(waypointsParam)&mode=driving&alternatives=true&key=\(apiKey)"
    guard let url = URL(string: urlString) else {
        DispatchQueue.main.async {
            completion("invalid url error", 0, "invalid url error", 0, nil)
        }
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        if error != nil {
            DispatchQueue.main.async {
                completion("error fetching data", 0, "error fetching data", 0, nil)
            }
            return
        }
        guard let data = data else {
            DispatchQueue.main.async {
                completion("no data received error", 0, "no data received error", 0, nil)
            }
            return
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let status = json["status"] as? String, status == "OK",
               let routes = json["routes"] as? [[String: Any]], !routes.isEmpty {
                var fastestRouteDuration: Double = Double.greatestFiniteMagnitude
                var shortestRouteDuration: Double = 0
                var fastestRoutePolyline: String = ""
                var shortestRoutePolyline: String = ""
                var shortestDistance: Double = Double.greatestFiniteMagnitude
                for route in routes {
                    if let polyline = (route["overview_polyline"] as? [String: Any])?["points"] as? String,
                       let legs = route["legs"] as? [[String: Any]] {
                        var totalDuration: Double = 0
                        var totalDistance: Double = 0
                        for leg in legs {
                            if let durationInfo = leg["duration"] as? [String: Any],
                               let durationValue = durationInfo["value"] as? Double {
                                totalDuration += durationValue
                            }
                            if let distanceInfo = leg["distance"] as? [String: Any],
                               let distanceValue = distanceInfo["value"] as? Double {
                                totalDistance += distanceValue
                            }
                        }
                        if totalDuration < fastestRouteDuration {
                            fastestRouteDuration = totalDuration
                            fastestRoutePolyline = polyline
                        }
                        if totalDistance < shortestDistance {
                            shortestDistance = totalDistance
                            shortestRouteDuration = totalDuration
                            shortestRoutePolyline = polyline
                        }
                    }
                }
                let fastestFormatted = formatDuration(seconds: fastestRouteDuration, arr: stoppedTime)
                let shortestFormatted = formatDuration(seconds: shortestRouteDuration, arr: stoppedTime)
                DispatchQueue.main.async {
                    completion(fastestFormatted, fastestRouteDuration, shortestFormatted, shortestRouteDuration, [fastestRoutePolyline, shortestRoutePolyline])
                }
            } else {
                DispatchQueue.main.async {
                    completion("no routes found", 0, "no routes found", 0, nil)
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion("error parsing json", 0, "error parsing json", 0, nil)
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
