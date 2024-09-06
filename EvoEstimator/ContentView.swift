//
//  ContentView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		ZStack {
			// Background color for the entire app
			Color.black.ignoresSafeArea(.all)
			
			VStack {
				// Title Section (VStack inside the overall ZStack)
				HStack {
					VStack(alignment: .leading) {
						Text("Evo")
							.font(Font.custom("Arya W00 Triple Slant", size: 32))
							.foregroundStyle(.white)
							.padding(.leading, 30)
						
						Text("Estimator")
							.font(Font.custom("Arya W00 Triple Slant", size: 24))
							.foregroundStyle(.white)
							.padding(.leading, 40)
						
						Spacer() // Pushes the text up to the top
					}
					Spacer() // Keeps the text on the left
				}
				.padding(.top, 30)
				.ignoresSafeArea(.container, edges: .top) // Raises the title higher near the notch
				
				// Button Section
				VStack(spacing: 20) { // Added spacing between buttons
					Button(action: {
						print("Entered Start Location")
					}) {
						Text("Start Location")
							.padding()
							.font(.system(size: 30, weight: .semibold))
							.background(Color.theme.accent)
							.foregroundColor(.white)
							.cornerRadius(90)
					}
					
					Spacer()
					
					Button(action: {
						print("Entered End Location")
					}) {
						Text("End Location")
							.padding()
							.font(.system(size: 30, weight: .semibold))
							.background(Color.theme.accent)
							.foregroundColor(.white)
							.cornerRadius(90)
					}
					
					Spacer()
					
					Button(action: {
						print("Trip Estimated!")
					}) {
						Text("Get my Estimate!")
							.padding()
							.font(.system(size: 30, weight: .semibold))
							.background(Color.theme.accent)
							.foregroundColor(.white)
							.cornerRadius(90)
					}
				}
				Spacer() // Pushes the buttons towards the center of the screen
			}
		}
	}
}

#Preview {
	ContentView()
}

