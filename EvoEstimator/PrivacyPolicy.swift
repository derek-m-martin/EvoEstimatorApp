//
//  PrivacyPolicy.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-13.
//

import SwiftUI

struct PrivacyPolicy: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color
                    Color.black.ignoresSafeArea()
                    
                    VStack {
                        // Title
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: geometry.size.height * 0.005) {
                                Text("Privacy Policy")
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
                        .padding(.top, geometry.size.height * 0.03)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                        
                        // Scrollable content
                        ScrollView {
                            VStack(alignment: .center, spacing: 20) {
                                // Privacy Policy Content
                                Group {
                                    Text("Last updated: December 31st, 2024")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 10)
                                    
                                    Text("Introduction")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("EvoEstimator is committed to protecting your privacy. This Privacy Policy describes how we collect, use, and disclose information when you use our mobile application (the \"App\"). By using the App, you agree to the collection and use of information in accordance with this policy.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Group {
                                    Text("Information We Collect")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("User-Provided Information")
                                        .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Entered Addresses: When you use the App to estimate trip costs, you may enter start and end locations. This information is used solely to provide you with the estimated trip cost and is immediately discarded afterwards and not stored in any way.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                    
                                    Text("Automatically Collected Information")
                                        .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("We do not collect any personal or non-personal information automatically. The App does not use cookies, tracking technologies, or analytics services.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("How We Use Your Information")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("Provide Services: The addresses you enter are used in real-time to call Google's Places and Distance Matrix APIs to calculate trip estimates.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                    
                                    Text("No Storage: We do not store, retain, or collect any of the addresses or data you input into the App on any backend servers or databases.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("Third-Party Services")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("Google APIs: The App utilizes Google's Places and Distance Matrix APIs to process the addresses you provide. Your use of these services is subject to Google's Privacy Policy. We do not control and are not responsible for the content or practices of Google's services.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("Data Security")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("While we do not store your data, we strive to use commercially acceptable means to protect the information transmitted during the use of the App. However, please remember that no method of transmission over the internet is 100% secure.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("Children's Privacy")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("Our App does not address anyone under the age of 13. We do not knowingly collect personal identifiable information from children under 13.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("Changes to This Privacy Policy")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App. Changes are effective immediately upon posting.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                                
                                Group {
                                    Text("Contact")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("If you have any questions or suggestions about this Privacy Policy, please contact derekmartin1005@gmail.com for clarification.")
                                        .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, geometry.size.width * 0.03)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicy()
}
