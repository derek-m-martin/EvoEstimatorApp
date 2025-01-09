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
        let coords = decodePolyline(encodedPolyline)
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
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
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: poly)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let id = "MapPin"
            var av = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if av == nil {
                av = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
                av?.canShowCallout = true
            } else {
                av?.annotation = annotation
            }
            return av
        }
    }
    
    private func decodePolyline(_ str: String) -> [CLLocationCoordinate2D] {
        let line = Polyline(encodedPolyline: str)
        return line.coordinates ?? []
    }
}
