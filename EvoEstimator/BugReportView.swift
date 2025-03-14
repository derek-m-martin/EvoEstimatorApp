//
//  BugReportView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-13.
//

import Foundation
import SwiftUI
import MessageUI

// gets device model info for bug reports
private struct MachineIdentifier {
    static func model() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // maps device identifiers to marketing names
        let modelMap: [String: String] = [
            // iPhone 12 Series
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            // iPhone 13 Series
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 Mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE (3rd generation)",
            // iPhone 14 Series
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            // iPhone 15 Series
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            // iPhone 16 Series
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus",
            "iPhone17,5": "iPhone 16 Pro",
            "iPhone17,6": "iPhone 16 Pro Max"
        ]
        
        return modelMap[identifier] ?? "iPhone"
    }
}

// handles bug report submission via emailjs
struct BugReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description = ""
    @State private var steps = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    // emailjs credentials
    private let serviceID = "service_eidwph6"
    private let templateID = "template_x0pzxcs"
    private let publicKey = "aMNLrr1571pK4EAKu"
    
    // gets device info for bug report
    private var deviceModel: String {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iPhone"
        return "Simulator (\(identifier))"
        #else
        return MachineIdentifier.model()
        #endif
    }
    
    // gets ios version for bug report
    private var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    // sends email using emailjs api
    func sendEmail() {
        isLoading = true
        
        let parameters: [String: Any] = [
            "service_id": serviceID,
            "template_id": templateID,
            "user_id": publicKey,
            "template_params": [
                "issuedesc": description,
                "reproduce": steps,
                "device": deviceModel,
                "version": "iOS \(systemVersion)",
                "accessToken": publicKey
            ],
            "accessToken": publicKey
        ]
        
        guard let url = URL(string: "https://api.emailjs.com/api/v1.0/email/send") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(publicKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        } catch {
            isLoading = false
            alertTitle = "Error"
            alertMessage = "Failed to prepare email data"
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    alertTitle = "Error"
                    alertMessage = "Failed to send email: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response body: \(responseString)")
                    }
                    
                    if httpResponse.statusCode == 200 {
                        alertTitle = "Success"
                        alertMessage = "Bug report sent successfully"
                        showAlert = true
                        description = ""
                        steps = ""
                    } else {
                        alertTitle = "Error"
                        alertMessage = "Failed to send email (Status: \(httpResponse.statusCode))"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
    
    // main view body
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("DESCRIPTION OF ISSUE")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    ) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                    
                    Section(header: Text("HOW TO REPRODUCE")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    ) {
                        TextEditor(text: $steps)
                            .frame(height: 100)
                    }
                    
                    Section(header: Text("DEVICE INFORMATION")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    ) {
                        HStack {
                            Text("Device Type:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(deviceModel)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("iOS Version:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(systemVersion)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Report an Issue")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    if description.isEmpty {
                        alertTitle = "Error"
                        alertMessage = "Please provide a description of the issue."
                        showAlert = true
                    } else {
                        sendEmail()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    } else {
                        Text("Send")
                    }
                }
                .disabled(isLoading)
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Success" {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    BugReportView()
}
