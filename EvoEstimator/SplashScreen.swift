//
//  SplashScreenView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-12.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var startOutroAnimation: Bool

    // OFFSETS FOR BEFORE COMING IN AND AFTER GOING OUT
    
    @State private var xOffsetTopE1: CGFloat = -1
    @State private var xOffsetTopE2: CGFloat = -1
    @State private var xOffsetTopE3: CGFloat = -1
    @State private var xOffsetTopE4: CGFloat = -1

    @State private var xOffsetBottomE1: CGFloat = 1
    @State private var xOffsetBottomE2: CGFloat = 1
    @State private var xOffsetBottomE3: CGFloat = 1
    @State private var xOffsetBottomE4: CGFloat = 1

    @State private var yOffsetTopE1: CGFloat = -1.0
    @State private var yOffsetTopE2: CGFloat = -1.0
    @State private var yOffsetTopE3: CGFloat = -1.0
    @State private var yOffsetTopE4: CGFloat = -1.0
    
    @State private var yOffsetBottomE1: CGFloat = 1.0
    @State private var yOffsetBottomE2: CGFloat = 1.0
    @State private var yOffsetBottomE3: CGFloat = 1.0
    @State private var yOffsetBottomE4: CGFloat = 1.0

    @State private var opacity: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                // Top "E" pieces
                Image("E_top_part_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetTopE1, y: geometry.size.height * yOffsetTopE1)
                    .opacity(opacity)

                Image("E_top_part_2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.075, height: geometry.size.height * 0.2)
                    .offset(x: xOffsetTopE2, y: geometry.size.height * yOffsetTopE2)
                    .opacity(opacity)

                Image("E_top_part_3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetTopE3, y: geometry.size.height * yOffsetTopE3)
                    .opacity(opacity)

                Image("E_top_part_4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetTopE4, y: geometry.size.height * yOffsetTopE4)
                    .opacity(opacity)
                    .zIndex(1)

                // Bottom "E" pieces
                Image("E_bottom_part_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetBottomE1, y: geometry.size.height * yOffsetBottomE1)
                    .opacity(opacity)

                Image("E_bottom_part_2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.075, height: geometry.size.height * 0.2)
                    .offset(x: xOffsetBottomE2, y: geometry.size.height * yOffsetBottomE2)
                    .opacity(opacity)

                Image("E_bottom_part_3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetBottomE3, y: geometry.size.height * yOffsetBottomE3)
                    .opacity(opacity)

                Image("E_bottom_part_4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.25)
                    .offset(x: xOffsetBottomE4, y: geometry.size.height * yOffsetBottomE4)
                    .opacity(opacity)
            }
            .onAppear {
                xOffsetTopE1 = -geometry.size.width * 0.03
                xOffsetTopE2 = -geometry.size.width * 0.13
                xOffsetTopE3 = -geometry.size.width * 0.03
                xOffsetTopE4 = -geometry.size.width * 0.03

                xOffsetBottomE1 = geometry.size.width * 0.07
                xOffsetBottomE2 = geometry.size.width * -0.02
                xOffsetBottomE3 = geometry.size.width * 0.07
                xOffsetBottomE4 = geometry.size.width * 0.07

                // Initialize Y Offsets for vertical movement
                yOffsetTopE1 = -1.0
                yOffsetTopE2 = -1.0
                yOffsetTopE3 = -1.0
                yOffsetTopE4 = -1.0

                yOffsetBottomE1 = 1.0
                yOffsetBottomE2 = 1.0
                yOffsetBottomE3 = 1.0
                yOffsetBottomE4 = 1.0

                opacity = 0

                withAnimation(.easeInOut(duration: 1.5)) {
                    yOffsetTopE1 = -0.14
                    yOffsetTopE2 = -0.07
                    yOffsetTopE3 = -0.07
                    yOffsetTopE4 = 0.0

                    yOffsetBottomE1 = 0.0
                    yOffsetBottomE2 = 0.07
                    yOffsetBottomE3 = 0.07
                    yOffsetBottomE4 = 0.14

                    opacity = 1
                }
            }
            .onChange(of: startOutroAnimation) {
                if startOutroAnimation {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        opacity = 0
                    }
                }
            }
        }
    }
}
