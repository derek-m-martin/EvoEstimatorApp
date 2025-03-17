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
                                    Text("I'm Derek, originally from Ontario but now a second year UBC computer science student. coding's been my passion since I was young.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Image("portrait")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.7)
                                        .padding(.horizontal, geometry.size.width * 0.11)
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 3, x: 0, y: 2)
                                    Text("When I'm not in Xcode or studying, I love the outdoors – hiking, snowboarding, or biking. My mom worries about me but such is life.")
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
                                    Text("I got annoyed trying to calculate evo trip costs, so I built this app to simplify things.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("I figured someone else might feel the same, so I turned my pet peeve into a fun project.")
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
                                    Text("I started with a web app idea, but switched to swift when I realized evo is app-based.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("Diving into swift and api docs was overwhelming at first, but super rewarding once I got the hang of it.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("After a lot of trial and error, everything started coming together, and I feel proud of the result.")
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
                                    Text("Over the past two updates I have implemented a lot of functionality, so while I wait for some ideas to come to me for new additions you can expect regular bug fixes and general reliability improvements to the app as well as ensuring it stays up-to-date with Evos pricing model.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Text("Feel free to send me any suggestions or ideas you may have in the meantime! I'd love to implement them.")
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
                                Text("Finally, from me to you:")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Text("THANKS FOR DOWNLOADING!")
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
