//
//  PrivacyPolicy.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2024-10-13.
//  Updated: March 17th, 2025
//

import SwiftUI

struct PrivacyPolicy: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack {
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

                        ScrollView {
                            VStack(alignment: .center, spacing: 25) {

                                Text("Last updated: March 17th, 2025")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                    .padding(.top,10)

                                Group {
                                    Text("Introduction")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
EvoEstimator is committed to protecting your privacy. This Privacy Policy describes how we collect, use, and disclose information when you use our mobile application (the "App"). By using the App, you agree to the collection and use of information in accordance with this policy.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Information We Collect")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("User-Provided Information")
                                        .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("""
• Entered Addresses: When you use the App to estimate trip costs, you may enter start/end locations and optional stops. This information is used solely to provide you with an estimated trip cost.
• Local Trip Saving: You may choose to save a trip, which stores the trip details (start/end locations, stops, and stop durations) locally on your device. This information is never uploaded to any server or shared with third parties.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    
                                    Text("Location & Device Data")
                                        .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("""
• Precise Location Data: If you opt to use the "Use Current Location" or "Find Nearby Evos" features, your device’s precise location is collected solely to prefill your starting location or to display nearby Evos within a 1km radius.
• Device Information: When using the "Report an Issue" feature, we automatically collect non-identifying details about your device (e.g., whether you are using an iPhone or iPad and your iOS version) to help diagnose issues.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    
                                    Text("Automatically Collected Information")
                                        .font(.system(size: geometry.size.width * 0.055, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("""
We do not collect any other personal or non-personal information automatically. The App does not use cookies, tracking technologies, or analytics services.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("How We Use Your Information")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
• Provide Services: The addresses you enter are used in real-time with Google's Places and Distance Matrix APIs to calculate trip estimates.
• Location Services: When you enable the "Use Current Location" feature, your precise location is used to quickly prefill your starting address. Additionally, the "Find Nearby Evos" feature utilizes your location to retrieve and display nearby Evos within a 1km radius.
• Report an Issue: Submissions from the "Report an Issue" page, including your device details and any reported bugs, are transmitted via EmailJS to our support team to help us improve the App.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)
                            
                                Group {
                                    Text("Third-Party Services")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
Google APIs: The App utilizes Google's Places and Distance Matrix APIs to process the addresses you provide. Your use of these services is subject to Google's Privacy Policy.

EmailJS: The "Report an Issue" feature uses EmailJS to send your anonymous reports along with device details. Your interaction with EmailJS is governed by its own Privacy Policy.

Evos API: The "Find Nearby Evos" feature calls the Evos API to display nearby Evos based on your current location.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Data Security")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
We take reasonable measures to protect any information you provide, including location and device details, during transmission and storage. However, no method of transmission over the internet or method of electronic storage is 100% secure.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Data Retention & Deletion")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
Trip details are stored locally on your device only when you explicitly choose to save them. Location data used for the "Use Current Location" and "Find Nearby Evos" features is processed in real-time and not stored long-term. Reports sent via the "Report an Issue" feature are transmitted directly to our support team and are not retained beyond what is necessary for issue resolution.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Children's Privacy")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
Our App does not address anyone under the age of 13. We do not knowingly collect personal identifiable information from children under 13.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Changes to This Privacy Policy")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App. Changes are effective immediately upon posting.
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                                
                                dividerLine(geometry: geometry)

                                Group {
                                    Text("Contact")
                                        .font(.system(size: geometry.size.width * 0.06, weight: .heavy))
                                        .foregroundColor(.white)
                                    
                                    Text("""
If you have any questions or suggestions about this Privacy Policy, please contact:
• derekmartin1005@gmail.com
""")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .light))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                }
                            }
                        }
                        .padding(.bottom, geometry.size.height * 0.02)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private func dividerLine(geometry: GeometryProxy) -> some View {
        Image("rounded_line")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width * 0.7)
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.horizontal, geometry.size.width * 0.11)
            .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    PrivacyPolicy()
}
