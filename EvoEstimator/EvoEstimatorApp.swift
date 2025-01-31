//
//  EvoEstimatorApp.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI

@main
struct EvoEstimatorApp: App {
    @State private var showSplashScreen = true
    @State private var startOutroAnimation = false

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView(startOutroAnimation: $startOutroAnimation)
                    .onAppear {
                        // Trigger the outro animation after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                startOutroAnimation = true
                            }
                        }
                        // Switch to MainView after the outro animation finishes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                    }
            } else {
                ViewHandler()
            }
        }
    }
}
