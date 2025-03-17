//
//  BugReportView.swift
//  EvoEstimator
//
//  Created by Derek Martin on 2025-03-13.
//

import Foundation
import SwiftUI
import MessageUI

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
    
    // simple device type check
    private var deviceModel: String {
        UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
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
                "from_name": "Evoestimator Bug Report",
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
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Email response: \(responseString)")
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Email status: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        alertTitle = "Success"
                        alertMessage = "Bug report sent successfully"
                        showAlert = true
                        description = ""
                        steps = ""
                    } else {
                        alertTitle = "Error"
                        alertMessage = "Failed to send email (status: \(httpResponse.statusCode))"
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
                    .ignoresSafeArea()
                Form {
                    Section(header: Text("Description of Issue")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }
                    Section(header: Text("How to Reproduce")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
                        TextEditor(text: $steps)
                            .frame(height: 100)
                    }
                    Section(header: Text("Device Information")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))) {
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
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
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
                dismissButton: .default(Text("Ok")) {
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
