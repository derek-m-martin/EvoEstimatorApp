//
//  MapViewToggler.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-13.
//

import Foundation
import SwiftUI
import MapKit

struct ToggleableMapView: View {
    let encodedPolyline: String
    let pins: [MapPinData]
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    @Binding var isFullscreen: Bool

    var body: some View {
        RouteMapView(encodedPolyline: encodedPolyline, pins: pins)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .onTapGesture {
                withAnimation {
                    isFullscreen = true
                }
            }
    }
}
