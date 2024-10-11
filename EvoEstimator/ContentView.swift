//
//  ContentView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-08-18.
//

import SwiftUI

struct ContentView: View {
	@State private var showingStartLocationPrompt = false
	@State private var showingEndLocationPrompt = false
	@State private var startLocation: String = ""
	@State private var endLocation: String = ""
	
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
				.padding(.top, 30) // keeps the title from hugging the very top of the screen
				.ignoresSafeArea(.container, edges: .top) // Raises the title higher near the notch
				
				// Button Section
				VStack(spacing: 20) { // Adjusted spacing between buttons and the dashed line
					// Start Location Button
					Button(action: {
						showingStartLocationPrompt = true
					}) {
						Text(startLocation.isEmpty ? "Start Location" : startLocation)
							.padding()
							.font(.system(size: 30, weight: .semibold))
							.background(Color.theme.accent)
							.foregroundColor(.white)
							.cornerRadius(90)
					}
					.sheet(isPresented: $showingStartLocationPrompt) {
						VStack {
							TextField("Enter Start Location", text: $startLocation)
								.padding()
								.textFieldStyle(RoundedBorderTextFieldStyle())
							Button("Finish") {
								showingStartLocationPrompt = false
							}
							.padding()
						}
						.padding()
					}
					
					// Dashed Line Image between Start and End Location
					Image("dash")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 65, height: 65)
						.foregroundColor(.white) // Forces image from black to white
					
					HStack(spacing: 12) { // Closer spacing between speed lines and car
						Image("plus")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 17, height: 17)
							.foregroundColor(.white)

						Text("Add Stops?")
							.font(.system(size: 24, weight: .light))
							.foregroundStyle(.white)
					}
					
					Image("dash")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 65, height: 65)
						.foregroundColor(.white)
					
					// End Location Button
					Button(action: {
						showingEndLocationPrompt = true
					}) {
						Text(endLocation.isEmpty ? "End Location" : endLocation)
							.padding()
							.font(.system(size: 30, weight: .semibold))
							.background(Color.theme.accent)
							.foregroundColor(.white)
							.cornerRadius(90)
					}
					.sheet(isPresented: $showingEndLocationPrompt) {
						VStack {
							TextField("Enter End Location", text: $endLocation)
								.padding()
								.textFieldStyle(RoundedBorderTextFieldStyle())
							Button("Finish") {
								showingEndLocationPrompt = false
							}
							.padding()
						}
						.padding()
					}

					// Car and Speed Lines Section
					HStack(spacing: -10) { // Closer spacing between speed lines and car
						Image("speed_lines")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 150, height: 50)
							.foregroundColor(.white)

						Image("car-skeleton")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 200, height: 150)
					}

					// "Get my Estimate" Button
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
