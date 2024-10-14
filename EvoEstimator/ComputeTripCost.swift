//
//  ComputeTripCost.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-11.
//

import Foundation

var perMin: Double = 0.49
var perTripCharge: Double = 1.25
var hourlyCharge: Double = 17.99
var dailyCharge = 104.99
var total = 0.0

func calculateCost(travelCost: Double, completion: @escaping (Double) -> Void) {
    let inMinutes = travelCost / 60
    if (inMinutes >= 37 && inMinutes <= 60) {
        total = hourlyCharge
    } else if (inMinutes > 60 && inMinutes < 360) {
        let numHours = floor(inMinutes / 60)
        let remaining = inMinutes - (numHours * 60)
        let step1 = (numHours * hourlyCharge)
        if (remaining < 37) {
            total = step1 + (remaining * perMin)
        } else {
            total = step1 + hourlyCharge
        }
    } else if (inMinutes >= 360) {
        total = dailyCharge
    } else {
        total = (inMinutes * perMin)
    }

    total += perTripCharge
    total = total.rounded(toPlaces: 2)
    total = (total * 1.12).rounded(toPlaces: 2)
    
    DispatchQueue.main.async {
        completion(total)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}




