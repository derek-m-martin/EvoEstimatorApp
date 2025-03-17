//
//  AppDelegate.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-10.
//

import Foundation
import UIKit
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey(APIKeys.googleAPIKey)
        return true
    }
}
