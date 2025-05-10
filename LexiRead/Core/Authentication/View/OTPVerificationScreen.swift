//
//  OTPVerificationScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/05/2025.
//

import SwiftUI

struct OTPVerificationScreen: View {
    @StateObject private var viewModel = OTPVerificationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Focus states for each field
    @FocusState private var focusField1: Bool
    @FocusState private var focusField2: Bool
    @FocusState private var focusField3: Bool
    @FocusState private var focusField4: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Title Section
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("LexiRead")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkerBlue))
                }
                
                VStack(spacing: 16) {
                    Text("Forget Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary900)
                    
                    Text("We will send you an OTP code via email, please enter it to confirm the transaction.")
                        .font(.system(size: 14))
                        .foregroundColor(.lrGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 50)
            
            // OTP Input Fields
            HStack(spacing: 16) {
                OTPTextField(text: $viewModel.otpDigits[0])
                    .focused($focusField1)
                    .onChange(of: viewModel.otpDigits[0]) { newValue in
                        if newValue.count == 1 { focusField2 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[1])
                    .focused($focusField2)
                    .onChange(of: viewModel.otpDigits[1]) { newValue in
                        if newValue.count == 1 { focusField3 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[2])
                    .focused($focusField3)
                    .onChange(of: viewModel.otpDigits[2]) { newValue in
                        if newValue.count == 1 { focusField4 = true }
                    }
                
                OTPTextField(text: $viewModel.otpDigits[3])
                    .focused($focusField4)
            }
            .padding(.horizontal, 24)
            
            // Resend Option
            HStack(spacing: 4) {
                Text("The code was not sent?")
                    .foregroundColor(.primary900)
                
                Button(action: viewModel.resendCode) {
                    Text("Resend it")
                        .foregroundColor(.lrYellow)
                }
            }
            .font(.system(size: 14))
            .padding(.top, 16)
            
            Spacer()
            
            // Confirmation Button
            Button(action: {
                viewModel.verifyOTP()
            }, label: {
                LRButton(
                    title: "Confirm",
                    isPrimary: true
                )
            })
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: BackButton {
//            presentationMode.wrappedValue.dismiss()
//        })
        .navigationDestination(isPresented: $viewModel.navigateToResetPasswordScreen) {
            ResetPasswordScreen()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            focusField1 = true
        }
    }
}

// MARK: - ViewModel
class OTPVerificationViewModel: ObservableObject {
    @Published var otpDigits: [String] = Array(repeating: "", count: 4)
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var navigateToResetPasswordScreen: Bool = false

    var otp: String {
        otpDigits.joined()
    }
    
    func verifyOTP() {
        guard otp.count == 4 else {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Please enter the complete OTP code"
            return
        }
        
        isLoading = true
        
        // API call placeholder using Alamofire
        // networkManager.verifyOTP(otp: otp) { [weak self] result in
        //     DispatchQueue.main.async {
        //         self?.isLoading = false
        //         switch result {
        //         case .success:
        //             // Navigate to Reset Password screen
        //             break
        //         case .failure(let error):
        //             self?.showAlert = true
        //             self?.alertTitle = "Error"
        //             self?.alertMessage = error.localizedDescription
        //         }
        //     }
        // }
        self.navigateToResetPasswordScreen = true
    }
    
    func resendCode() {
        // Implement resend code logic here
        // This should call the same API endpoint as the initial code send
    }
}

#Preview {
    OTPVerificationScreen()
}


// MARK: - OTP TextField
struct OTPTextField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 80, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary900, lineWidth: 1)
            )
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
            }
    }
}
