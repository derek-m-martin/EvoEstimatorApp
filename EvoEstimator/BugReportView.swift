import SwiftUI
import MessageUI

struct BugReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description = ""
    @State private var steps = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isShowingMailView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Report an Issue")
                                .font(.system(size: geometry.size.width * 0.08, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: geometry.size.width, alignment: .center)
                                .shadow(
                                    color: Color.theme.accent.opacity(1),
                                    radius: 1.2,
                                    x: -2,
                                    y: 2
                                )
                                .padding(.top, 20)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Issue Description")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextEditor(text: $description)
                                    .frame(height: 150)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.theme.accent, lineWidth: 1)
                                    )
                                
                                Text("Steps to Reproduce (Optional)")
                                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                TextEditor(text: $steps)
                                    .frame(height: 150)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.theme.accent, lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                if description.isEmpty {
                                    alertTitle = "Error"
                                    alertMessage = "Please provide a description of the issue."
                                    showAlert = true
                                } else {
                                    sendEmail()
                                }
                            }) {
                                Text("Submit Report")
                                    .padding()
                                    .frame(maxWidth: geometry.size.width * 0.8)
                                    .background(Color.theme.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.theme.accent.opacity(1), radius: 5, x: 0, y: 2)
                            }
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: $result, description: description, steps: steps)
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        } else {
            alertTitle = "Error"
            alertMessage = "Your device is not configured to send emails. Please ensure you have an email account set up."
            showAlert = true
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    let description: String
    let steps: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            if let error = error {
                self.result = .failure(error)
            } else {
                self.result = .success(result)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                         result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["derekmartin1005@gmail.com"])
        vc.setSubject("EvoEstimator Bug Report")
        
        let deviceInfo = """
        
        ---------------------
        Device Information:
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        Device Name: \(UIDevice.current.name)
        """
        
        let emailBody = """
        Issue Description:
        \(description)
        
        Steps to Reproduce:
        \(steps.isEmpty ? "Not provided" : steps)
        \(deviceInfo)
        """
        
        vc.setMessageBody(emailBody, isHTML: false)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    }
}

#Preview {
    BugReportView()
} 