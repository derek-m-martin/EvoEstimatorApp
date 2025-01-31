//
//  ResultView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-30.
//

import Foundation
import SwiftUI

struct ResultView: View {
    var body: some View {
        VStack {}
        
        //ZStack {
        //    if errorOccurred {
        //        Text("An Error Has Occurred")
        //            .font(.system(size: geometry.size.width * 0.05, weight: .bold))
        //            .foregroundColor(.red)
        //            .offset(x: estimateAnimation ? 0 : -geometry.size.width)
        //            .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
        //    } else {
        //
        //        VStack(spacing: geometry.size.height * 0.03) {
        //
        //            VStack(spacing: geometry.size.height * 0.01) {
        //                Text("Estimated Travel Time: \(travelTime)")
        //                    .font(.system(size: geometry.size.width * 0.045, weight: .bold))
        //                    .foregroundColor(Color.theme.accent)
        //                    .offset(x: estimateAnimation ? 0 : -geometry.size.width)
        //                    .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
        //                Text("Estimated Stop Duration: \(formatStopDuration(finalStopSeconds))")
        //                    .font(.system(size: geometry.size.width * 0.045, weight: .bold))
        //                    .foregroundColor(Color.theme.accent)
        //                    .offset(x: estimateAnimation ? 0 : -geometry.size.width)
        //                    .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
        //                Text("Estimated Trip Price: $\(String(format: "%.2f", tripCost))")
        //                    .font(.system(size: geometry.size.width * 0.045, weight: .bold))
        //                    .foregroundColor(Color.theme.accent)
        //                    .offset(x: estimateAnimation ? 0 : -geometry.size.width)
        //                    .animation(.easeInOut(duration: 1.2), value: estimateAnimation)
        //            }
        //            if !errorOccurred && !travelTime.isEmpty {
        //                Button {
        //                    showDirectionsOptions = true
        //                } label: {
        //                    Text("Get Directions")
        //                        .padding()
        //                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
        //                        .frame(maxWidth: geometry.size.width * 0.55)
        //                        .background(Color.theme.accent)
        //                        .foregroundColor(.white)
        //                        .cornerRadius(geometry.size.width * 0.05)
        //                        .background(
        //                            RoundedRectangle(cornerRadius: geometry.size.width * 0.05)
        //                                .stroke(Color.theme.accent, lineWidth: 3)
        //                        )
        //                }
        //                .confirmationDialog("Open with?", isPresented: $showDirectionsOptions) {
        //                    Button("Apple Maps") { openInAppleMaps() }
        //                    Button("Google Maps") { openInGoogleMaps() }
        //                    Button("Cancel", role: .cancel) { }
        //                }
        //            }
        //            if let validPolyline = primaryPolyline,
        //               !validPolyline.isEmpty,
        //               !errorOccurred {
        //                ToggleableMapView(
        //                    primaryPolyline: primaryPolyline ?? "",
        //                    alternativePolylines: alternativePolylines,
        //                    mapPins: mapPins,
        //                    width: geometry.size.width * 0.8,
        //                    height: geometry.size.height * 0.3,
        //                    cornerRadius: geometry.size.width * 0.05,
        //                    shadowColor: Color.theme.accent.opacity(1),
        //                    shadowRadius: 5,
        //                    shadowX: 0,
        //                    shadowY: 2,
        //                    isFullscreen: $isMapFullscreen
        //                )
        //                .padding(.bottom, 30)
        //            }
        //        }
        //    }
        //}
        //
        //}
        //}
        //if isMapFullscreen {
        //Color.black.opacity(0.5)
        //.ignoresSafeArea()
        //.onTapGesture {
        //    withAnimation {
        //        isMapFullscreen = false
        //    }
        //}
        //if let primaryPolyline = primaryPolyline {
        //RouteMapView(
        //    primaryPolyline: primaryPolyline,
        //    alternativePolylines: alternativePolylines,
        //    pins: mapPins
        //)
        //.scaledToFill()
        //.ignoresSafeArea()
        //.onTapGesture {
        //    withAnimation {
        //        isMapFullscreen = false
        //    }
        //}
        //.zIndex(1)
        //}
        //}
    }
}


//extension ResultView {
//    
//    func openInAppleMaps() {
//        
//        guard let startCoord = startCoordinate,
//              let endCoord   = endCoordinate else {
//            return
//        }
//        
//        var mapItems = [MKMapItem]()
//        
//        let startPlacemark = MKPlacemark(coordinate: startCoord)
//        let startItem      = MKMapItem(placemark: startPlacemark)
//        startItem.name     = startLocation
//        mapItems.append(startItem)
//        
//        for (i, stopName) in stops.enumerated() {
//            guard !stopName.isEmpty else { continue }
//            
//            if stopsCoordinates.indices.contains(i),
//               let coord = stopsCoordinates[i] {
//                let stopPlacemark = MKPlacemark(coordinate: coord)
//                let stopItem      = MKMapItem(placemark: stopPlacemark)
//                stopItem.name     = stopName
//                mapItems.append(stopItem)
//            } else {
//            }
//        }
//        
//        let endPlacemark = MKPlacemark(coordinate: endCoord)
//        let endItem      = MKMapItem(placemark: endPlacemark)
//        endItem.name     = endLocation
//        mapItems.append(endItem)
//        
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
//    }
//    
//    func openInGoogleMaps() {
//        
//        let baseScheme  = "comgooglemaps://"
//        let webFallback = "https://maps.google.com/"
//        
//        func encode(_ s: String) -> String {
//            return s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
//        }
//        
//        if let url = URL(string: baseScheme), UIApplication.shared.canOpenURL(url) {
//            
//            var urlString = "comgooglemaps://?saddr=\(encode(startLocationForRouting))"
//            
//            if stops.isEmpty {
//                urlString += "&daddr=\(encode(endLocationForRouting))"
//            } else {
//                
//                var encounteredFirstStop = false
//                
//                var stopsString = ""
//                for stopName in stops {
//                    guard !stopName.isEmpty else { continue }
//                    
//                    if !encounteredFirstStop {
//                        stopsString += "\(encode(stopName))"
//                        encounteredFirstStop = true
//                    } else {
//                        stopsString += "+to:\(encode(stopName))"
//                    }
//                }
//                
//                stopsString += "+to:\(encode(endLocationForRouting))"
//                
//                urlString += "&daddr=" + stopsString
//            }
//            
//            urlString += "&directionsmode=driving"
//            
//            if let directionsURL = URL(string: urlString) {
//                UIApplication.shared.open(directionsURL)
//            }
//        } else {
//            
//            let urlString = "\(webFallback)?saddr=\(encode(startLocationForRouting))&daddr=\(encode(endLocationForRouting))"
//            if let fallbackURL = URL(string: urlString) {
//                UIApplication.shared.open(fallbackURL)
//            }
//        }
//    }
//}

