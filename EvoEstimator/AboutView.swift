//
//  AboutPage.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-13.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack { // using nav stack for smooth page transitions
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea() // set background to black
                    VStack {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Text("About the Developer/App")
                                    .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: geometry.size.width, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 1.2, x: -2, y: 2)
                            }
                            Spacer()
                        }
                        .padding(.top, geometry.size.height * 0.05)
                        .padding(.horizontal)
                        Image("rounded_line")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.7)
                            .padding(.top, 6)
                            .padding(.horizontal, geometry.size.width * 0.11)
                            .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                        Spacer(minLength: 30)
                        ScrollView {
                            VStack(alignment: .center, spacing: 25) {
                                Group {
                                    Text("Who I Am")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    Text("i'm derek, originally from ontario but now a second year ubc computer science student. coding's been my passion since i was young.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Image("portrait")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.7)
                                        .padding(.horizontal, geometry.size.width * 0.11)
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 3, x: 0, y: 2)
                                    Text("when i'm not in xcode or studying, i love the outdoors – hiking, snowboarding, or biking. my mom worries, but it's all good.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 6)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                Group {
                                    Text("Why Create This?")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    Text("i got annoyed trying to calculate evo trip costs, so i built this app to simplify things.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("i figured someone else might feel the same, so i turned my pet peeve into a fun project.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 6)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                Group {
                                    Text("The Development Process")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    Text("i started with a web app idea, but switched to swift when i realized evo is app-based.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("diving into swift and api docs was overwhelming at first, but super rewarding once i got the hang of it.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("after a lot of trial and error, everything started coming together, and i feel proud of the result.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 6)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                Group {
                                    Text("What Comes Next?")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    Text("right now, i've got basic a-b calculations and stops. more features are on the way.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("expect future updates with more travel options and smoother functionality!")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                Image("rounded_line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geometry.size.width * 0.7)
                                    .padding(.top, 6)
                                    .padding(.horizontal, geometry.size.width * 0.11)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                                Text("finally, from me to you:")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Text("thanks for downloading!")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .heavy))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
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
