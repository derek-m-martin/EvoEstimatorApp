//
//  UserTips.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-30.
//

import Foundation
import SwiftUI

struct UserTipsView: View {
    let tips = [
        "Did you know? Evo allows one-way trips, so you don’t have to return the car to where you picked it up!",
        "Always end your trip in an Evo Home Zone to avoid additional charges.",
        "Gas is included! Snap a photo of your fuel receipt and send it to Evo for reimbursement!",
        "You can park in residential permit zones within the Evo Home Zone for free.",
        "Avoid service fees—make sure the car is clean and free of garbage before ending your trip.",
        "You can park at any metered spot in the homezone without charge #CarShareFreebie"
    ]
    
    @State private var currentTipIndex = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {

            Text(tips[currentTipIndex])
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.theme.background)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)

            HStack {
                ForEach(0..<tips.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTipIndex ? Color.white : Color.gray)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 5)
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentTipIndex = (currentTipIndex + 1) % tips.count
            }
        }
    }
}
