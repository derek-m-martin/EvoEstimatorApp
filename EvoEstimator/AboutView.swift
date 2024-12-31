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
                                Text("About the Developer/App")
                                    .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: geometry.size.width, alignment: .center)
                                    .multilineTextAlignment(.center)
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
                        
                        Image("rounded_line")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.7)
                            .padding(.top, 6)
                            .padding(.horizontal, geometry.size.width * 0.11)
                            .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                        
                        Spacer(minLength: 30)

                        // Scrollable content
                        ScrollView {
                            VStack(alignment: .center, spacing: 25) {
                                // About Content
                                
                                Group {
            
                                    Text("Who I Am")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("I'm Derek, originally from Ontario but now a second year student at the University of British Columbia pursuing Computer Science. I've loved to code since I was young and have followed that path ever since with the support of my parents and family.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Image("portrait")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width * 0.7)
                                        .padding(.horizontal, geometry.size.width * 0.11)
                                        .shadow(color: Color.theme.accent.opacity(1), radius: 3, x: 0, y: 2)
                                    
                                    Text("When I'm not buried head deep in XCode working on this, studying for exams, or working my job I enjoy the outdoors (Vancouver duh) and am usually hiking, snowboarding, or mountain biking much to the dismay of my Mom who worries about me from across the country.")
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
                                    
                                    Text("Out of all the possible apps and creations in the world, this idea grew from a little pet peeve of mine. I, along with the rest of Vancouver are lucky to have the Evo Carshare service. The issue with this is sometimes you may be on a budget, or just want to know how much your Evo trip may cost, and that wasn't readily available because I'd have to go to google maps, see how long it would take, and then calculate the cost based on their tiered fare pricing.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("While a fairly minor annoyance, I figured I must not be the only one who thinks this and that it would be a good pet project to work on and to gain some new skills in the process, even if it may not be used by many.")
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
                                    
                                    Text("Initially I was going to make a web application, but a good friend pointed out that Evo is app-based, so it only makes sense. While a good idea, this meant I had to utilize iOS' development language, Swift which I had no previous experience with, and thus the work began to familiarize myself.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Once I finally started to get better with Swift, then came the backend. I assumed using Google's API's was straightforward plug and play - this was not the case. As my first dive into API's the amount of documentation and the like was overwhelming but with a LOT of trial and error I made it work and man did it feel great!")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("With those two new skills the sailing then became smooth(er) and I was able to put this app together which I am quite proud of and has been an extremely educational journey which took a lot of perseverance, but here we are.")
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
                                    
                                    Text("As I am writing this, only the basic functionality has been implemented such as point A - B calculations, or with intermediary stops such as point A - B - C, etc.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Once I manage to get this published, (which it likely is if you're reading this), then I will be developing further additions such as travel method comparisons such as real time transit, rideshare, and more. As well as allowing intermediary stop durations, and just refining the app to be as pleasant to use as possible!")
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
                                
                                Text("THANK YOU FOR SUPPORTING BY DOWNLOADING!")
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
