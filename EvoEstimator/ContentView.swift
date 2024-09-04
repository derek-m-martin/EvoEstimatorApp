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
            // sets background colour to black
            Color.black
                .edgesIgnoringSafeArea(.all) // ensures colour covers entire screen

            VStack(
            ) {
                
                // creating the title in top left of screen
                
                HStack {
                    
                    VStack (
                        alignment: .leading
                    ) {
                        
                        Text("Evo")
							.font(Font.custom("Arya W00 Triple Slant", size: 32))
                            .foregroundStyle(.white)
                        
                        Text("Estimator")
							.font(Font.custom("Arya W00 Triple Slant", size: 32))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

