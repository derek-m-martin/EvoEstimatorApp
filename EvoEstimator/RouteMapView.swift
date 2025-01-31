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
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays) // Clear previous overlays

        // main route (quickest)
        let primaryCoords = decodePolyline(primaryPolyline)
        let primaryPolyline = MKPolyline(coordinates: primaryCoords, count: primaryCoords.count)
        primaryPolyline.title = "primary"
        uiView.addOverlay(primaryPolyline)

        for (index, route) in alternativePolylines.enumerated() {
            let alternativeCoords = decodePolyline(route)
            let alternativePolyline = MKPolyline(coordinates: alternativeCoords, count: alternativeCoords.count)
            alternativePolyline.title = "alternative\(index)"
            uiView.addOverlay(alternativePolyline)
        }

        let mapRect = uiView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
        uiView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: false)

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

            if polyline.title == "primary" {
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
            } else if polyline.title?.contains("0") == true {
                renderer.strokeColor = .systemPurple.withAlphaComponent(1)
                renderer.lineWidth = 3
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
