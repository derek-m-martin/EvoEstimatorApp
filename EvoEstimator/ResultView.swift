//
//  ResultView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-30.
//

import SwiftUI
import MapKit
import CoreLocation
import Contacts

// displays the final route details and estimates
struct ResultView: View {
    let errorOccurred: Bool
    let travelTime: String
    let travelTimeValue: Double
    let tripCost: Double
    let finalStopSeconds: Int
    let startLocation: String
    let endLocation: String
    let stops: [String]
    let routingStart: String
    let routingEnd: String
    let routingStops: [String]
    let startCoordinate: CLLocationCoordinate2D?
    let endCoordinate: CLLocationCoordinate2D?
    let stopsCoordinates: [CLLocationCoordinate2D?]
    let primaryPolyline: String?
    @Binding var showResultView: Bool
    @Binding var fadeToBlack: Bool
    @State private var showDirectionsOptions = false
    @State private var isMapFullscreen = false
    
    var onCloseEstimate: (() -> Void)?
    
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
    
    // formats stop duration into readable string
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
    
    // opens route in apple maps
    func openInAppleMaps() {
        var items: [MKMapItem] = []
        
        // Add start location
        if let start = startCoordinate {
            let startPlacemark = MKPlacemark(coordinate: start, addressDictionary: [CNPostalAddressStreetKey: routingStart])
            let startItem = MKMapItem(placemark: startPlacemark)
            startItem.name = startLocation
            items.append(startItem)
        }
        
        // Add stops in order
        for (index, stopCoord) in stopsCoordinates.enumerated() {
            if let coord = stopCoord, stops.indices.contains(index) {
                let stopPlacemark = MKPlacemark(coordinate: coord, addressDictionary: [CNPostalAddressStreetKey: routingStops[index]])
                let stopItem = MKMapItem(placemark: stopPlacemark)
                stopItem.name = stops[index]
                items.append(stopItem)
            }
        }
        
        // Add end location
        if let end = endCoordinate {
            let endPlacemark = MKPlacemark(coordinate: end, addressDictionary: [CNPostalAddressStreetKey: routingEnd])
            let endItem = MKMapItem(placemark: endPlacemark)
            endItem.name = endLocation
            items.append(endItem)
        }
        
        guard items.count >= 2 else { return }
        
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey: true
        ] as [String : Any]
        
        MKMapItem.openMaps(with: items, launchOptions: options)
    }
    
    // opens route in google maps
    func openInGoogleMaps() {
        // Try to use the app first
        var urlComponents = URLComponents(string: "comgooglemaps://")
        urlComponents?.queryItems = []
        
        // Add start location using address
        urlComponents?.queryItems?.append(URLQueryItem(name: "saddr", value: routingStart))
        
        // Add end location using address
        urlComponents?.queryItems?.append(URLQueryItem(name: "daddr", value: routingEnd))
        
        // Add waypoints using addresses
        if !routingStops.isEmpty {
            let waypointsString = routingStops.joined(separator: "|")
            urlComponents?.queryItems?.append(URLQueryItem(name: "waypoints", value: waypointsString))
        }
        
        urlComponents?.queryItems?.append(URLQueryItem(name: "directionsmode", value: "driving"))
        
        if let url = urlComponents?.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to web URL if app is not installed
                var webComponents = URLComponents(string: "https://www.google.com/maps/dir/")
                webComponents?.queryItems = [
                    URLQueryItem(name: "api", value: "1"),
                    URLQueryItem(name: "origin", value: routingStart),
                    URLQueryItem(name: "destination", value: routingEnd),
                    URLQueryItem(name: "travelmode", value: "driving")
                ]
                
                if !routingStops.isEmpty {
                    webComponents?.queryItems?.append(URLQueryItem(name: "waypoints", value: routingStops.joined(separator: "|")))
                }
                
                if let webUrl = webComponents?.url {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    // creates route elements for display
    struct RouteElement: Identifiable {
        let id = UUID()
        let text: String
        let showArrow: Bool
    }
    
    // generates array of route elements from locations
    var routeElements: [RouteElement] {
        var elements: [RouteElement] = []
        
        if !startLocation.isEmpty {
            elements.append(RouteElement(text: startLocation, showArrow: !stops.isEmpty || !endLocation.isEmpty))
        }
        
        for (index, stop) in stops.enumerated() {
            elements.append(RouteElement(text: stop, showArrow: index < stops.count - 1 || !endLocation.isEmpty))
        }
        
        if !endLocation.isEmpty {
            elements.append(RouteElement(text: endLocation, showArrow: false))
        }
        
        return elements
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                if let validPolyline = primaryPolyline, !errorOccurred {
                    RouteMapView(
                        primaryPolyline: validPolyline,
                        alternativePolylines: [],
                        pins: mapPins
                    )
                    .frame(width: geometry.size.width * 0.8,
                           height: geometry.size.height * 0.4)
                    .cornerRadius(20)
                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                    .onTapGesture {
                        isMapFullscreen = true
                    }
                } else {
                    Text("No Route Available")
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 0) {
                    Text("Route")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(routeElements, id: \.id) { element in
                                HStack(spacing: 4) {
                                    Text(element.text)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    if element.showArrow {
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: geometry.size.width * 0.8)
                    .background(Color.theme.accent.opacity(0.9))
                    .cornerRadius(20)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 0) {
                    Text("Estimates")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                    
                    VStack(spacing: 10) {
                        Text("Travel Time: \(travelTime)")
                            .font(.headline)
                            .foregroundColor(.white)
                        if !stops.isEmpty {
                            Text("Stop Duration: \(formatStopDuration(finalStopSeconds))")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Text("Trip Price: $\(String(format: "%.2f", tripCost))")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: geometry.size.width * 0.7)
                    .background(Color.theme.accent.opacity(0.9))
                    .cornerRadius(20)
                }
                .padding(.bottom, 30)
                .padding(.top, 15)
                .padding(.horizontal, 20)
                
                HStack(spacing: 20) {
                    Button {
                        showDirectionsOptions = true
                    } label: {
                        Text("Get Directions")
                            .padding()
                            .frame(maxWidth: geometry.size.width * 0.4)
                            .background(Color.theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .font(.headline)
                    }
                    
                    .confirmationDialog("Open with?", isPresented: $showDirectionsOptions) {
                        Button("Apple Maps") { openInAppleMaps() }
                        Button("Google Maps") { openInGoogleMaps() }
                        Button("Cancel", role: .cancel) { }
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            fadeToBlack = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showResultView = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    fadeToBlack = false
                                }
                                onCloseEstimate?()
                            }
                        }
                    } label: {
                        Text("Close Estimate")
                            .padding()
                            .frame(maxWidth: geometry.size.width * 0.4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .font(.headline)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, 30)
            .background(Color.black.ignoresSafeArea())
            .fullScreenCover(isPresented: $isMapFullscreen) {
                ZStack(alignment: .topTrailing) {
                    if let validPolyline = primaryPolyline, !errorOccurred {
                        RouteMapView(
                            primaryPolyline: validPolyline,
                            alternativePolylines: [],
                            pins: mapPins
                        )
                        .ignoresSafeArea()
                        .onTapGesture {
                            isMapFullscreen = false
                        }
                    } else {
                        Color.black.ignoresSafeArea()
                    }
                }
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
        routingStart: "New York, NY",
        routingEnd: "Boston, MA",
        routingStops: ["Hartford, CT"],
        startCoordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        endCoordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
        stopsCoordinates: [
            CLLocationCoordinate2D(latitude: 41.7658, longitude: -72.6734)
        ],
        primaryPolyline: "somePrimaryEncodedPolylineString",
        showResultView: .constant(true),
        fadeToBlack: .constant(false)
    )
}
