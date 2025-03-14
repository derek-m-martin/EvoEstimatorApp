//
//  TripSelectorView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-31.
//

import SwiftUI

// view for selecting and managing saved trips
struct TripSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tripStorage: TripStorage
    let onTripSelected: (SavedTrip) -> Void
    
    // formats date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
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
                                dismiss()
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
                        dismiss()
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
