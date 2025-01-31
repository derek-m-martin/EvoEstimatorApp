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
    
    @State private var showDirectionsOptions = false
    
    var mapPins: [MapPinData] {
        var pins = [MapPinData]()
        if let startCoord = startCoordinate {
            pins.append(MapPinData(coordinate: startCoord, title: startLocation))
        }
        for (index, stopCoord) in stopsCoordinates.enumerated() {
            if let coord = stopCoord, stops.indices.contains(index) {
                pins.append(MapPinData(coordinate: coord, title: stops[index]))
            }
        }
        if let endCoord = endCoordinate {
            pins.append(MapPinData(coordinate: endCoord, title: endLocation))
        }
        return pins
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let validPolyline = primaryPolyline, !errorOccurred {
                RouteMapView(
                    primaryPolyline: validPolyline,
                    alternativePolylines: [],
                    pins: mapPins
                )
                .frame(width: UIScreen.main.bounds.width * 0.9,
                       height: UIScreen.main.bounds.height * 0.3)
                .cornerRadius(15)
                .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
            } else {
                Text("No Route Available")
                    .foregroundColor(.red)
            }
            VStack(spacing: 10) {
                Text("Estimated Travel Time: \(travelTime)")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Text("Estimated Stop Duration: \(formatStopDuration(finalStopSeconds))")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Text("Estimated Trip Price: $\(String(format: "%.2f", tripCost))")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            Button {
                showDirectionsOptions = true
            } label: {
                Text("Get Directions")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .confirmationDialog("Open with?", isPresented: $showDirectionsOptions) {
                Button("Apple Maps") { openInAppleMaps() }
                Button("Google Maps") { openInGoogleMaps() }
                Button("Cancel", role: .cancel) { }
            }
            Spacer()
        }
        .padding(.top, 20)
        .background(Color.black.ignoresSafeArea())
    }
    
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
}

extension ResultView {
    func openInAppleMaps() {
        guard let startCoord = startCoordinate, let endCoord = endCoordinate else { return }
        var mapItems = [MKMapItem]()
        let startPlacemark = MKPlacemark(coordinate: startCoord)
        let startItem = MKMapItem(placemark: startPlacemark)
        startItem.name = startLocation
        mapItems.append(startItem)
        for (i, stopName) in stops.enumerated() {
            if stopsCoordinates.indices.contains(i), let coord = stopsCoordinates[i] {
                let stopPlacemark = MKPlacemark(coordinate: coord)
                let stopItem = MKMapItem(placemark: stopPlacemark)
                stopItem.name = stopName
                mapItems.append(stopItem)
            }
        }
        let endPlacemark = MKPlacemark(coordinate: endCoord)
        let endItem = MKMapItem(placemark: endPlacemark)
        endItem.name = endLocation
        mapItems.append(endItem)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
    }
    
    func openInGoogleMaps() {
        let baseScheme = "comgooglemaps://"
        let webFallback = "https://maps.google.com/"
        func encode(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }
        if let url = URL(string: baseScheme), UIApplication.shared.canOpenURL(url) {
            var urlString = "comgooglemaps://?saddr=\(encode(startLocation))"
            if stops.isEmpty {
                urlString += "&daddr=\(encode(endLocation))"
            } else {
                var stopsString = stops.compactMap { encode($0) }.joined(separator: "+to:")
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

#Preview {
    ResultView(
        errorOccurred: false,
        travelTime: "1h 30m",
        travelTimeValue: 5400,
        tripCost: 25.75,
        finalStopSeconds: 1800,
        startLocation: "New York, NY",
        endLocation: "Boston, MA",
        stops: ["Hartford, CT"],
        startCoordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        endCoordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
        stopsCoordinates: [CLLocationCoordinate2D(latitude: 41.7658, longitude: -72.6734)],
        primaryPolyline: "somePrimaryEncodedPolylineString"
    )
}
