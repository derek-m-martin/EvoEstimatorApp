//
//  ResultView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-30.
//

import SwiftUI
import MapKit
import CoreLocation

struct ResultView: View {
    let errorOccurred: Bool
    let travelTime: String
    let travelTimeValue: Double
    let tripCost: Double
    let finalStopSeconds: Int
    let startLocation: String
    let endLocation: String
    let stops: [String]
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?
    let stopsCoordinates: [CLLocationCoordinate2D?]
    let primaryPolyline: String?
    let alternativePolylines: [String]
    
    @State private var isMapFullscreen = false
    @State private var showDirectionsOptions = false
    @State private var showOverlayBlack = true

    func formatStopDuration(_ totalSeconds: Int) -> String {
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        var components: [String] = []
        if days > 0 { components.append("\(days) day\(days == 1 ? "" : "s")") }
        if hours > 0 { components.append("\(hours) hour\(hours == 1 ? "" : "s")") }
        if minutes > 0 { components.append("\(minutes) minute\(minutes == 1 ? "" : "s")") }
        if components.isEmpty { return "0 minutes" }
        return components.joined(separator: ", ")
    }

    private var mapPins: [MapPinData] {
        var pins = [MapPinData]()
        if let startCoord = startCoordinate, !startLocation.isEmpty {
            pins.append(MapPinData(coordinate: startCoord, title: startLocation))
        }
        for (i, stopName) in stops.enumerated() {
            if stopsCoordinates.indices.contains(i),
               let coord = stopsCoordinates[i],
               !stopName.isEmpty {
                pins.append(MapPinData(coordinate: coord, title: stopName))
            }
        }
        if let endCoord = endCoordinate, !endLocation.isEmpty {
            pins.append(MapPinData(coordinate: endCoord, title: endLocation))
        }
        return pins
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            // This ZStack is basically your old result block from MainView
            ZStack {
                if errorOccurred {
                    Text("An Error Has Occurred")
                        .font(.system(size: geometry.size.width * 0.05, weight: .bold))
                        .foregroundColor(.red)

                } else {
                    VStack(spacing: geometry.size.height * 0.03) {
                        VStack(spacing: geometry.size.height * 0.01) {
                            Text("Estimated Travel Time: \(travelTime)")
                                .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                .foregroundColor(Color.theme.accent)

                            Text("Estimated Stop Duration: \(formatStopDuration(finalStopSeconds))")
                                .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                .foregroundColor(Color.theme.accent)

                            Text("Estimated Trip Price: $\(String(format: "%.2f", tripCost))")
                                .font(.system(size: geometry.size.width * 0.045, weight: .bold))
                                .foregroundColor(Color.theme.accent)
                        }

                        if !errorOccurred && !travelTime.isEmpty {
                            Button {
                                showDirectionsOptions = true
                            } label: {
                                Text("Get Directions")
                                    .padding()
                                    .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                                    .frame(maxWidth: geometry.size.width * 0.55)
                                    .background(Color.theme.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(geometry.size.width * 0.05)
                                    .background(
                                        RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
                                            .stroke(Color.theme.accent, lineWidth: 3)
                                    )
                            }
                            .confirmationDialog("Open with?", isPresented: $showDirectionsOptions) {
                                Button("Apple Maps") { openInAppleMaps() }
                                Button("Google Maps") { openInGoogleMaps() }
                                Button("Cancel", role: .cancel) { }
                            }
                        }

                        if let validPolyline = primaryPolyline,
                           !validPolyline.isEmpty,
                           !errorOccurred {
                            ToggleableMapView(
                                primaryPolyline: validPolyline,
                                alternativePolylines: alternativePolylines,
                                mapPins: mapPins,
                                width: geometry.size.width * 0.8,
                                height: geometry.size.height * 0.3,
                                cornerRadius: geometry.size.width * 0.05,
                                shadowColor: Color.theme.accent.opacity(1),
                                shadowRadius: 5,
                                shadowX: 0,
                                shadowY: 2,
                                isFullscreen: $isMapFullscreen
                            )
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())

            if isMapFullscreen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMapFullscreen = false
                        }
                    }
                if let primaryPolyline {
                    RouteMapView(
                        primaryPolyline: primaryPolyline,
                        alternativePolylines: alternativePolylines,
                        pins: mapPins
                    )
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isMapFullscreen = false
                        }
                    }
                    .zIndex(1)
                }
            }
        }
    }
}

extension ResultView {
    func openInAppleMaps() {
        guard let startCoord = startCoordinate,
              let endCoord   = endCoordinate else {
            return
        }
        
        var mapItems = [MKMapItem]()
        
        let startPlacemark = MKPlacemark(coordinate: startCoord)
        let startItem      = MKMapItem(placemark: startPlacemark)
        startItem.name     = startLocation
        mapItems.append(startItem)
        
        for (i, stopName) in stops.enumerated() {
            guard !stopName.isEmpty else { continue }
            
            if stopsCoordinates.indices.contains(i),
               let coord = stopsCoordinates[i] {
                let stopPlacemark = MKPlacemark(coordinate: coord)
                let stopItem      = MKMapItem(placemark: stopPlacemark)
                stopItem.name     = stopName
                mapItems.append(stopItem)
            }
        }
        
        let endPlacemark = MKPlacemark(coordinate: endCoord)
        let endItem      = MKMapItem(placemark: endPlacemark)
        endItem.name     = endLocation
        mapItems.append(endItem)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
    }
    
    func openInGoogleMaps() {
        let baseScheme  = "comgooglemaps://"
        let webFallback = "https://maps.google.com/"
        
        func encode(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }
        
        if let url = URL(string: baseScheme), UIApplication.shared.canOpenURL(url) {
            var urlString = "comgooglemaps://?saddr=\(encode(startLocation))"
            
            if stops.isEmpty {
                urlString += "&daddr=\(encode(endLocation))"
            } else {
                var encounteredFirstStop = false
                var stopsString = ""
                for stopName in stops {
                    guard !stopName.isEmpty else { continue }
                    
                    if !encounteredFirstStop {
                        stopsString += "\(encode(stopName))"
                        encounteredFirstStop = true
                    } else {
                        stopsString += "+to:\(encode(stopName))"
                    }
                }
                stopsString += "+to:\(encode(endLocation))"
                urlString += "&daddr=" + stopsString
            }
            
            urlString += "&directionsmode=driving"
            
            if let directionsURL = URL(string: urlString) {
                UIApplication.shared.open(directionsURL)
            }
        } else {
            let urlString = "\(webFallback)?saddr=\(encode(startLocation))&daddr=\(encode(endLocation))"
            if let fallbackURL = URL(string: urlString) {
                UIApplication.shared.open(fallbackURL)
            }
        }
    }
}
