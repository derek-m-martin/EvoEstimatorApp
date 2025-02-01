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
                                HStack(spacing: 4) {
                                    Text(trip.displayStartLocation)
                                    if !trip.displayStops.isEmpty {
                                        Text("→")
                                        ForEach(trip.displayStops, id: \.self) { stop in
                                            Text(stop)
                                            Text("→")
                                        }
                                    }
                                    Text(trip.displayEndLocation)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
}
