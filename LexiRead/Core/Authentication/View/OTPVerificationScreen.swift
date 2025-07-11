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
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingView()
                }
            }
        )
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: BackButton())
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


#Preview {
    OTPVerificationScreen()
}
