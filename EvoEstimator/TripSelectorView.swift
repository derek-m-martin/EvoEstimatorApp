//
//  TripSelectorView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import SwiftUI

struct TripSelectorView: View {
    @ObservedObject var tripStorage: TripStorage
    var onTripSelected: (Trip) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if tripStorage.trips.isEmpty {
                    Text("No saved trips yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(tripStorage.trips) { trip in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(trip.name)
                                    .font(.headline)

                                HStack(spacing: 8) {
                                    ForEach(buildRouteElements(
                                        start: trip.displayStartLocation,
                                        stops: trip.displayStops,
                                        end: trip.displayEndLocation
                                    ), id: \.self) { element in
                                        HStack(spacing: 4) {
                                            Text(element.text)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            if element.showArrow {
                                                Image(systemName: "arrow.right")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                onTripSelected(trip)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Load")
                                    .padding(8)
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .onDelete(perform: tripStorage.deleteTrip)
                }
            }
            .navigationTitle("Saved Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private struct RouteElement: Hashable {
        let text: String
        let showArrow: Bool
    }
    
    private func buildRouteElements(start: String, stops: [String], end: String) -> [RouteElement] {
        var elements: [RouteElement] = []

        elements.append(RouteElement(text: start, showArrow: !stops.isEmpty || !end.isEmpty))

        for (index, stop) in stops.enumerated() {
            let isLastStop = index == stops.count - 1
            let hasEnd = !end.isEmpty
            elements.append(RouteElement(text: stop, showArrow: !isLastStop || hasEnd))
        }

        if !end.isEmpty {
            elements.append(RouteElement(text: end, showArrow: false))
        }
        
        return elements
    }
}
