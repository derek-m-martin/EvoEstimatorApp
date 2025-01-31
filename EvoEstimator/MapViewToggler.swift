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
    let primaryPolyline: String
    let alternativePolylines: [String]
    let mapPins: [MapPinData]
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowX: CGFloat
    let shadowY: CGFloat
    @Binding var isFullscreen: Bool

    var body: some View {
        RouteMapView(
            primaryPolyline: primaryPolyline,
            alternativePolylines: alternativePolylines,
            pins: mapPins
        )
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
