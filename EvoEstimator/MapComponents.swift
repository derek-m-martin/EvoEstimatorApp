//
//  MapComponents.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-14.
//

import SwiftUI
import MapKit
import CoreLocation
import Polyline
import Contacts

// data structure for map pins
struct MapPinData {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let car: EvoCar?
    
    init(coordinate: CLLocationCoordinate2D, title: String, car: EvoCar? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.car = car
    }
}

// base protocol for map view functionality
protocol MapViewBase {
    var showsUserLocation: Bool { get }
    var delegate: MKMapViewDelegate? { get }
    
    func makeMapView() -> MKMapView
    func updateMapView(_ mapView: MKMapView)
}

// annotation for evo cars on the map
class EvoAnnotation: MKPointAnnotation {
    var car: EvoCar?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, car: EvoCar?) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.car = car
    }
}

// popup view for evo car details
struct EvoDetailPopup: View {
    let car: EvoCar
    let address: String
    let distance: Double
    let onDismiss: () -> Void
    let onUseForStartLocation: (String) -> Void
    @State private var showDirectionsOptions = false
    
    // open in apple maps
    private func openInAppleMaps() {
        let destination = CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude)
        let placemark = MKPlacemark(coordinate: destination, addressDictionary: [CNPostalAddressStreetKey: address])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Evo Car (\(car.plate)) - \(address)"
        
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
            MKLaunchOptionsShowsTrafficKey: true
        ] as [String : Any]
        
        mapItem.openInMaps(launchOptions: options)
    }
    
    // open in google maps
    private func openInGoogleMaps() {
        var urlComponents = URLComponents(string: "comgooglemaps://")
        urlComponents?.queryItems = [
            URLQueryItem(name: "daddr", value: address),
            URLQueryItem(name: "directionsmode", value: "driving")
        ]
        
        if let url = urlComponents?.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                var webComponents = URLComponents(string: "https://www.google.com/maps/dir/")
                webComponents?.queryItems = [
                    URLQueryItem(name: "api", value: "1"),
                    URLQueryItem(name: "destination", value: address),
                    URLQueryItem(name: "travelmode", value: "driving")
                ]
                
                if let webUrl = webComponents?.url {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // header with title and close button
            HStack {
                Text("Evo Details")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text("Plate: \(car.plate)")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text(address)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "fuelpump.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text("Fuel: \(car.fuelLevel ?? 0)%")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
                
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    Text(String(format: "%.2f km away", distance))
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal)
            
            // action buttons for directions and start location
            VStack(spacing: 12) {
                Button {
                    showDirectionsOptions = true
                } label: {
                    Text("Directions")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                }
                
                Button {
                    onUseForStartLocation(address)
                    onDismiss()
                } label: {
                    Text("Use for Start Location")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 300)
        .background(Color.theme.accent)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
        .confirmationDialog("Open with?", isPresented: $showDirectionsOptions) {
            Button("Apple Maps") { openInAppleMaps() }
            Button("Google Maps") { openInGoogleMaps() }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// loading popup view for finding evos
struct LoadingPopup: View {
    var body: some View {
        VStack(spacing: 16) {
            // header with title
            HStack {
                Text("Finding Nearby Evos")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
                
                Text("Searching within 1km of your location...")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
        }
        .frame(width: 300)
        .background(Color.theme.accent)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

// map view for showing evos with pins and user location
struct EvoMapView: UIViewRepresentable {
    let pins: [MapPinData]
    @Binding var selectedCar: EvoCar?
    @Binding var selectedCarAddress: String
    @Binding var selectedCarDistance: Double
    let userLocation: CLLocationCoordinate2D?
    var onUseForStartLocation: (String) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false // disable 3d pitch
        mapView.isRotateEnabled = false // no rotation please
        mapView.showsCompass = false // hide compass
        mapView.showsScale = true // show scale info
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations: [EvoAnnotation] = []
        var coordinates: [CLLocationCoordinate2D] = []
        
        for pin in pins {
            if let car = pin.car {
                let annotation = EvoAnnotation(
                    coordinate: pin.coordinate,
                    title: pin.title,
                    car: car
                )
                annotations.append(annotation)
                coordinates.append(pin.coordinate)
            }
        }
        
        if let userLocation = userLocation {
            coordinates.append(userLocation)
        }
        
        mapView.addAnnotations(annotations)
        
        if !coordinates.isEmpty {
            mapView.fitAll(coordinates: coordinates)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // map delegate to handle pin taps
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: EvoMapView
        
        init(_ parent: EvoMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "EvoPin"
            var view: MKMarkerAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            view.markerTintColor = .systemBlue
            view.glyphImage = UIImage(systemName: "car.fill")
            view.canShowCallout = false
            view.displayPriority = .required
            view.clusteringIdentifier = nil
            
            return view
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let evoAnnotation = annotation as? EvoAnnotation,
                  let car = evoAnnotation.car else {
                return
            }
            
            let location = CLLocation(latitude: car.latitude, longitude: car.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first {
                        let address = [
                            placemark.subThoroughfare,
                            placemark.thoroughfare,
                            placemark.locality
                        ].compactMap { $0 }.joined(separator: " ")
                        
                        let distance: Double
                        if let userLocation = self.parent.userLocation {
                            print("calculating distance using user location: \(userLocation)")
                            let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                            let carLoc = CLLocation(latitude: car.latitude, longitude: car.longitude)
                            distance = userLoc.distance(from: carLoc) / 1000.0
                            print("distance: \(distance)km")
                        } else {
                            print("no user location available, using map view location")
                            if let mapUserLocation = mapView.userLocation.location {
                                let carLoc = CLLocation(latitude: car.latitude, longitude: car.longitude)
                                distance = mapUserLocation.distance(from: carLoc) / 1000.0
                                print("distance (map view): \(distance)km")
                            } else {
                                print("user location missing completely")
                                distance = 0.0
                            }
                        }
                        
                        self.parent.selectedCarAddress = address
                        self.parent.selectedCarDistance = distance
                        self.parent.selectedCar = car
                    }
                }
            }
            
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}

// route map view for drawing travel paths
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
        
        let mapRect = uiView.overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
        uiView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
        
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
    
    // delegate for rendering route overlays
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
    
    // decode a polyline string to coordinates
    private func decodePolyline(_ str: String) -> [CLLocationCoordinate2D] {
        let line = Polyline(encodedPolyline: str)
        return line.coordinates ?? []
    }
}

// view modifier to toggle fullscreen map view
struct MapViewToggler: ViewModifier {
    @Binding var isFullscreen: Bool
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                withAnimation {
                    isFullscreen = true
                }
            }
            .fullScreenCover(isPresented: $isFullscreen) {
                content
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFullscreen = false
                    }
            }
    }
}

extension View {
    // make a view toggle fullscreen on tap
    func toggleableFullscreen(isFullscreen: Binding<Bool>) -> some View {
        modifier(MapViewToggler(isFullscreen: isFullscreen))
    }
}

extension MKCoordinateRegion {
    // init region from a set of coordinates
    init(coordinates: [CLLocationCoordinate2D], latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        guard !coordinates.isEmpty else {
            self = MKCoordinateRegion()
            return
        }
        
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, latitudinalMeters / 111000),
            longitudeDelta: max((maxLon - minLon) * 1.5, longitudinalMeters / 111000)
        )
        
        self.init(center: center, span: span)
    }
    
    var mapRect: MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: center.latitude + span.latitudeDelta/2,
            longitude: center.longitude - span.longitudeDelta/2
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: center.latitude - span.latitudeDelta/2,
            longitude: center.longitude + span.longitudeDelta/2
        )
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(
            x: min(a.x, b.x),
            y: min(a.y, b.y),
            width: abs(a.x - b.x),
            height: abs(a.y - b.y)
        )
    }
}

extension MKMapView {
    // adjust map view to show all given coordinates
    func fitAll(coordinates: [CLLocationCoordinate2D], animated: Bool = true) {
        guard !coordinates.isEmpty else { return }
        
        let points = coordinates.map { MKMapPoint($0) }
        var rect = MKMapRect(origin: points[0], size: MKMapSize(width: 0, height: 0))
        
        points.forEach { point in
            rect = rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
        }
        
        let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        setVisibleMapRect(rect, edgePadding: padding, animated: animated)
    }
}