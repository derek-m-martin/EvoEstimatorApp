//
//  BugReportView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-13.
//

import Foundation
import SwiftUI
import MessageUI

// helper to get device model info for bug reports
private struct MachineIdentifier {
    static func model() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        // mapping device identifiers to user-friendly names
        let modelMap: [String: String] = [
            "iPhone13,1": "iphone 12 mini",
            "iPhone13,2": "iphone 12",
            "iPhone13,3": "iphone 12 pro",
            "iPhone13,4": "iphone 12 pro max",
            "iPhone14,2": "iphone 13 pro",
            "iPhone14,3": "iphone 13 pro max",
            "iPhone14,4": "iphone 13 mini",
            "iPhone14,5": "iphone 13",
            "iPhone14,6": "iphone se (3rd generation)",
            "iPhone14,7": "iphone 14",
            "iPhone14,8": "iphone 14 plus",
            "iPhone15,2": "iphone 14 pro",
            "iPhone15,3": "iphone 14 pro max",
            "iPhone15,4": "iphone 15",
            "iPhone15,5": "iphone 15 plus",
            "iPhone16,1": "iphone 15 pro",
            "iPhone16,2": "iphone 15 pro max",
            "iPhone17,3": "iphone 16",
            "iPhone17,4": "iphone 16 plus",
            "iPhone17,5": "iphone 16 pro",
            "iPhone17,6": "iphone 16 pro max"
        ]
        return modelMap[identifier] ?? "iphone"
    }
}

struct BugReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description = ""
    @State private var steps = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    // emailjs credentials
    private let serviceID = "service_i22yqcb"
    private let templateID = "template_x0pzxcs"
    private let publicKey = "aMNLrr1571pK4EAKu"
    private let privateKey = "hBuWWOwh-KTYLbq7UhqhG"
    
    // get device model string for bug report
    private var deviceModel: String {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iphone"
        return "simulator (\(identifier))"
        #else
        return MachineIdentifier.model()
        #endif
    }
    
    private var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    func sendEmail() {
        isLoading = true
        let parameters: [String: Any] = [
            "service_id": serviceID,
            "template_id": templateID,
            "user_id": publicKey,
            "accessToken": privateKey,
            "template_params": [
                "from_name": "evoestimator bug report",
                "issuedesc": description,
                "reproduce": steps,
                "device": deviceModel,
                "version": "ios \(systemVersion)"
            ]
        ]
        
        guard let url = URL(string: "https://api.emailjs.com/api/v1.0/email/send") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
            // print out request body for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("sending bug report: \(jsonString)")
            }
        } catch {
            isLoading = false
            alertTitle = "error"
            alertMessage = "failed to prepare email data"
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    alertTitle = "error"
                    alertMessage = "failed to send email: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("email response: \(responseString)")
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("email status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        alertTitle = "success"
                        alertMessage = "bug report sent successfully"
                        showAlert = true
                        description = ""
                        steps = ""
                    } else {
                        alertTitle = "error"
                        alertMessage = "failed to send email (status: \(httpResponse.statusCode))"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea() // use system background
                Form {
                    Section(header: Text("description of issue")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                    Section(header: Text("how to reproduce")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
                        TextEditor(text: $steps)
                            .frame(height: 100)
                    }
                    Section(header: Text("device information")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
                        HStack {
                            Text("device type:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(deviceModel)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("ios version:")
                                .foregroundColor(.white)
                            Spacer()
                            Text(systemVersion)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("report an issue")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    if description.isEmpty {
                        alertTitle = "error"
                        alertMessage = "please provide a description of the issue."
                        showAlert = true
                    } else {
                        sendEmail()
                    }
                }) {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    } else {
                        Text("send")
                    }
                }
                .disabled(isLoading)
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("ok")) {
                    if alertTitle == "success" {
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
