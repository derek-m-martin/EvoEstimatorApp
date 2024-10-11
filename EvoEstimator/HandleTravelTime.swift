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

func estimateTripTime(startAddress: String, endAddress: String) {
    let apiKey = APIKeys.googleAPIKey
    let originsEncoded = startAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let destinationsEncoded = endAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(originsEncoded)&destinations=\(destinationsEncoded)&mode=driving&key=\(apiKey)"
    
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
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let rows = json["rows"] as? [[String: Any]],
               let elements = rows.first?["elements"] as? [[String: Any]],
               let duration = elements.first?["duration"] as? [String: Any],
               let travelTimeText = duration["text"] as? String {
                
                // Print the estimated travel time
                print("Estimated Travel Time: \(travelTimeText)")
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }.resume()
}
