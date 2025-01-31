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
    let primaryPolyline: String
    let alternativePolylines: [String]
    let pins: [MapPinData]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        // Decode the primary polyline and add it to the map
        let primaryCoords = decodePolyline(primaryPolyline)
        let primaryPolylineOverlay = MKPolyline(coordinates: primaryCoords, count: primaryCoords.count)
        primaryPolylineOverlay.title = "fastest"
        uiView.addOverlay(primaryPolylineOverlay)

        if let shortestPolyline = alternativePolylines.first {
            let shortestCoords = decodePolyline(shortestPolyline)
            let shortestPolylineOverlay = MKPolyline(coordinates: shortestCoords, count: shortestCoords.count)
            shortestPolylineOverlay.title = "shortest"
            uiView.addOverlay(shortestPolylineOverlay)
        }

        // Adjust map to fit all overlays
        let mapRect = uiView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
        uiView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)

        // Add pins for start, stops, and end locations
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)

            if polyline.title == "fastest" {
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
            } else if polyline.title == "shortest" {
                renderer.strokeColor = .systemPurple
                renderer.lineWidth = 5
            }
            return renderer
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
