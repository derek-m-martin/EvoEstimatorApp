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
                        // Title
                        Text("Evo's Rates Breakdown")
                            .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(
                                color: Color.theme.accent.opacity(1),
                                radius: 1.2,
                                x: -2,
                                y: 2
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, geometry.size.height * 0.03)
                            .padding(.horizontal)

                        Spacer(minLength: 30)
                        
                        // Scrollable content
                        ScrollView {
                            VStack(spacing: 20) {
                                
                                // Description Text
                                Text("We get it. Evo is not the easiest to understand in terms of their rates, so here we'll give you an easy to understand explanation which is also how EvoEstimator calculates your price estimate – so you will have no ambiguity the next time you decide to take a ride!")
                                .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, geometry.size.width * 0.03)
                                
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 25)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                
                                // Rates Breakdown Section
                                VStack(spacing: 20) {
                                    VStack {
                                        Text("All Access Fee: ")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .light))
                                            .foregroundColor(.white)
                                        + Text("$1.85")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "exclamationmark.square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.05)
                                        
                                        Text("A fixed fee charged by Evo per-trip regardless of duration (is only charged after you unlock the vehicle)")
                                            .font(.system(size: geometry.size.width * 0.03, weight: .light))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)

                                    VStack {
                                        Text("Per-Minute: ")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .light))
                                            .foregroundColor(.white)
                                        + Text("49¢")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "exclamationmark.square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.05)
                                        
                                        Text("Applies for trips with duration between 1 and 36 minutes in duration")
                                            .font(.system(size: geometry.size.width * 0.03, weight: .light))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)

                                    VStack {
                                        Text("Per-Hour: ")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .light))
                                            .foregroundColor(.white)
                                        + Text("$17.99")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "exclamationmark.square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.05)
                                        
                                        Text("Applies for trips with duration between 37 minutes and 1 hour in duration")
                                            .font(.system(size: geometry.size.width * 0.03, weight: .light))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)

                                    VStack {
                                        Text("Per-Day: ")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .light))
                                            .foregroundColor(.white)
                                        + Text("$104.99")
                                            .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 10) {
                                        Image(systemName: "exclamationmark.square")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.05)
                                        
                                        Text("Applies for trips with duration between 6 and 24 hours in duration")
                                            .font(.system(size: geometry.size.width * 0.03, weight: .light))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .padding(.horizontal)

                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 25)
                                    .padding(.horizontal, geometry.size.width * 0.1)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                
                                VStack(spacing: 20) {
                                    Text("The most important thing to understand is their dynamic pricing model which we specified with the exclamation-marked captions below the prices. Evo prices this way to ensure you always pay the least amount possible. So while it may seem complicated, it actually benefits you – and our EvoEstimator does the calculations the same way, but BEFORE your trip, not after!")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                }
                                
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 25)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                
                                VStack(spacing: 10) {
                                    Text("Additional Information:")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)
                                    
                                    Text("- The 30 minute reservation window is not counted towards your trip duration")
                                        .font(.system(size: geometry.size.width * 0.05, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    
                                    Text("- There is 12% tax applied to your total fare + set trip cost when you end your trip (EvoEstimator accounts for this)")
                                        .font(.system(size: geometry.size.width * 0.05, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                    
                                    Text("""
- EvoEstimator's price estimate is typically accurate within $1 but is an estimate based on various factors at the time of estimate. If traffic changes, a different route is chosen, or you do not drive continuously, the estimate will lose accuracy
""")
                                    .font(.system(size: geometry.size.width * 0.05, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RatesView()
}
