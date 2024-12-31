//
//  AboutPage.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-13.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color
                    Color.black.ignoresSafeArea()
                    
                    VStack {
                        // Title and DropDown Menu
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Text("About the App")
                                    .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: geometry.size.width, alignment: .center)
                                    .shadow(
                                        color: Color.theme.accent.opacity(1),
                                        radius: 1.2,
                                        x: -2,
                                        y: 2
                                    )
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.top, geometry.size.height * 0.05)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                        
                        // Scrollable content
                        ScrollView {
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Hello World")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
