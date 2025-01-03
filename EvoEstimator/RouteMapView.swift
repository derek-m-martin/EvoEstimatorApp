//
//  RouteMapView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-02.
//

import SwiftUI
import MapKit
import CoreLocation
import Polyline

struct MapPinData {
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct RouteMapView: UIViewRepresentable {
    let encodedPolyline: String
    let pins: [MapPinData]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let coordinates = decodePolyline(encodedPolyline)

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        mapView.setVisibleMapRect(
            polyline.boundingMapRect,
            edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
            animated: false
        )

        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title
            mapView.addAnnotation(annotation)
        }

        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // placeholder function required by mapkit or else will error!!!!!!
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

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            let identifier = "MapPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
    
    // pulled off the internet as all it does is decode how Google's API compresses polylines (lat/long coordinate pairs)
    // credit to my man raphael: https://swiftpackageindex.com/raphaelmor/Polyline
    private func decodePolyline(_ encodedString: String) -> [CLLocationCoordinate2D] {
        let polyline = Polyline(encodedPolyline: encodedString)
        return polyline.coordinates ?? []
    }
}
