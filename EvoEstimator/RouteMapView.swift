//
//  RouteMapView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-02.
//

import SwiftUI
import MapKit
import CoreLocation

struct RouteMapView: UIViewRepresentable {
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // placeholder for if it needs updating, requirement of mapkit
    }
    
    let encodedPolyline: String
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let coordinates = decodePolyline(encodedPolyline)

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        mapView.setVisibleMapRect(polyline.boundingMapRect,
                                  edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
                                  animated: false)
        
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    private func decodePolyline(_ encodedString: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let utf8String = encodedString.utf8
        var index = utf8String.startIndex
        let endIndex = utf8String.endIndex
        
        var lat: Int32 = 0
        var lng: Int32 = 0
        
        while index < endIndex {
            var result: Int32 = 0
            var shift: Int32 = 0
            var byte: Int32
            
            repeat {
                byte = Int32(utf8String[index]) - 63
                utf8String.formIndex(after: &index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20
            
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat &+= dlat
            
            result = 0
            shift = 0
            
            repeat {
                guard index < endIndex else { break }
                byte = Int32(utf8String[index]) - 63
                utf8String.formIndex(after: &index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20
            
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng &+= dlng
            
            let finalLat = Double(lat) / 1E5
            let finalLng = Double(lng) / 1E5
            
            coordinates.append(CLLocationCoordinate2D(latitude: finalLat, longitude: finalLng))
        }
        return coordinates
    }
}

