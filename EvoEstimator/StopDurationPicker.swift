//
//  StopDurationPicker.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-01-03.
//

import SwiftUI

struct StopPickerView: View {
    @Binding var currentStopDuration: Int
    @Binding var showOrNot: Bool
    
    private let data: [[String]] = [
        Array(0...7).map { "\($0)" },
        Array(0...24).map { "\($0)" },
        Array(0...60).map { "\($0)" }
    ]

    @State private var selections: [Int] = [0, 0, 0]
    @State private var close: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 30) {
                    Text("Select a Duration")
                        .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(
                            color: Color.theme.accent.opacity(1),
                            radius: 1.2,
                            x: -2,
                            y: 2
                        )
                    
                    PickerView(data: self.data, selections: self.$selections)
                        .padding()
                        .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .background(Color.theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(geometry.size.width * 0.05)
                        .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                    
                    HStack(spacing: 30) {
                        Text("Days: \(self.data[0][self.selections[0]])")
                            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(
                                color: Color.theme.accent.opacity(1),
                                radius: 1.2,
                                x: -2,
                                y: 2
                            )
                        
                        Text("Hours: \(self.data[1][self.selections[1]])")
                            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(
                                color: Color.theme.accent.opacity(1),
                                radius: 1.2,
                                x: -2,
                                y: 2
                            )
                        
                        Text("Minutes: \(self.data[2][self.selections[2]])")
                            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(
                                color: Color.theme.accent.opacity(1),
                                radius: 1.2,
                                x: -2,
                                y: 2
                            )
                    }
                    
                    Button(action: {
                        let daysVal = Int(self.data[0][self.selections[0]]) ?? 0
                        let hoursVal = Int(self.data[1][self.selections[1]]) ?? 0
                        let minsVal = Int(self.data[2][self.selections[2]]) ?? 0
                        let total = daysVal * 86400 + hoursVal * 3600 + minsVal * 60
                        currentStopDuration = total
                        self.showOrNot = false
                    }) {
                        Text("Confirm!")
                            .padding()
                            .font(.system(size: geometry.size.width * 0.05, weight: .semibold))
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .background(Color.theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(geometry.size.width * 0.05)
                            .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                    }
                }
            }
        }
    }
}
