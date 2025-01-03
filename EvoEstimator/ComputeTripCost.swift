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

func calculateCost(travelCost: Double, completion: @escaping (Double) -> Void) {
    // Convert travelCost (seconds) to minutes
    let inMinutes = travelCost / 60

    // If travel time is zero or invalid, cost is zero
    if inMinutes <= 0 {
        DispatchQueue.main.async {
            completion(0)
        }
        return
    }

    let fullDays = floor(inMinutes / 1440)
    let leftoverMinutes = inMinutes.truncatingRemainder(dividingBy: 1440)

    var totalCost = fullDays * dailyCharge

    let leftoverDayCost = costForLessThanOneDay(leftoverMinutes)
    totalCost += leftoverDayCost

    totalCost += perTripCharge

    totalCost = (totalCost * 1.12).rounded(toPlaces: 2)

    DispatchQueue.main.async {
        completion(totalCost)
    }
}

private func costForLessThanOneDay(_ inMinutes: Double) -> Double {
    var partialDayCost: Double = 0.0

    if inMinutes <= 0 {
        return 0
    }

    if inMinutes >= 37 && inMinutes <= 60 {
        partialDayCost = hourlyCharge

    } else if inMinutes > 60 && inMinutes < 360 {
        let numHours = floor(inMinutes / 60)
        let remaining = inMinutes - (numHours * 60)
        let baseHourCost = numHours * hourlyCharge

        if remaining < 37 {
            partialDayCost = baseHourCost + (remaining * perMin)
        } else {
            partialDayCost = baseHourCost + hourlyCharge
        }

    } else if inMinutes >= 360 {
        partialDayCost = dailyCharge

    } else {
        partialDayCost = inMinutes * perMin
    }

    return partialDayCost.rounded(toPlaces: 2)
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
