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

func estimateTripTime(start: String, end: String) {
    guard !start.isEmpty, !end.isEmpty else {
        print("Start or End location is missing")
        return
    }
    
    let apiKey = APIKeys.googleAPIKey
    let startEncoded = start.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let endEncoded = end.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startEncoded)&destination=\(endEncoded)&key=\(apiKey)"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data received")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let routes = json["routes"] as? [[String: Any]],
               let legs = routes.first?["legs"] as? [[String: Any]],
               let duration = legs.first?["duration"] as? [String: Any],
               let travelTimeText = duration["text"] as? String {
                
                print("Estimated Travel Time: \(travelTimeText)")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }.resume()
}
