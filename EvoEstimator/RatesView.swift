//
//  RatesView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-12.
//

import SwiftUI

struct RatesView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color
                    Color.black.ignoresSafeArea()
                    VStack {
                        // Title and DropDown Menu
                        HStack {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Text("Evo's Rates Breakdown")
                                    .padding(.top, geometry.size.height * 0.05)
                                    .padding(.trailing, geometry.size.width * 0.23)
                                    .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                                    .frame(maxWidth: geometry.size.width * 0.8)
                                    .foregroundColor(.white)
                                    .cornerRadius(geometry.size.width * 0.05)
                                    .shadow(
                                        color: Color.theme.accent.opacity(1),
                                        radius: 1.2,
                                            x: -2,
                                            y: 2
                                        )
                            }
                            
                            Spacer()
                            
                            // Dropdown menu!
                            Menu {
                                NavigationLink("Back to the Estimator", destination: MainView())
                                NavigationLink("About the App", destination: AboutView())
                                NavigationLink("Our Privacy Policy", destination: PrivacyPolicy())
                            } label: {
                                Image(systemName: "line.horizontal.3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.08)
                                    .foregroundColor(.white)
                                    .padding(.top, geometry.safeAreaInsets.top + geometry.size.height * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.05)
                            }
                        }
                        Spacer()
                        
                        VStack {
                            
                            Text("We get it. Evo is not the easiest to understand in terms of their rates, so here we'll give you an easy to understand explanation which is also how EvoEstimator calculates your price estimate - so you will have no ambiguity the next time you decide to take a ride!")
                                .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, geometry.size.height * 0.045)
                                .padding(.bottom, geometry.size.height * 0.03)
                                .padding(.trailing, geometry.size.width * 0.02)
                                .padding(.leading, geometry.size.width * 0.053)

                            Image("rounded_line")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.7)
                                .padding(.bottom, geometry.size.height * 0.1)

                            Spacer()

                        }
                        
                        .frame(maxHeight: .infinity)
                        
                    }
                }
            }
        }
    }
}
 

#Preview {
    RatesView()
}
