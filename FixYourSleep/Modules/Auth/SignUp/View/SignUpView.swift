//
//  AuthView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isTermsAndViewChecked = false
    @State private var isSheetingPresented = false
    @EnvironmentObject var router: RouterManager
    @StateObject private var viewModel: SignUpViewModel
    @EnvironmentObject private var userStateManager: UserStateManager
    
    init(viewModel: SignUpViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            inputFields
            termsAndView
            signUpButton
            CustomDivider()
                .padding(.vertical, 8)
            socialSignUpButtons
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .background(.blackBg)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: userStateManager.authState) { oldValue, newValue in
            if newValue == .signedIn {
                if let user = userStateManager.fysUser {
                    if user.goalSleepingTime != nil {
                        router.navigateTo(to: .home)
                    } else {
                        router.navigateTo(to: .onBoarding)
                    }
                }
            }
        }
        .sheet(isPresented: $isSheetingPresented) {
            TermsAndPrivacySheet(isPresented: $isSheetingPresented)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.backward")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .onTapGesture {
                        router.navigateBack()
                    }
                Spacer()
            }
            .padding(.vertical)
            Text("Create Account")
                .font(.albertSans(.semibold, size: 32))
                .onLongPressGesture {
                    let date = Date()
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    // Fill test data
                    username = "testuser"
                    email = String(format: "%02d%02d@gmail.com", hour, minute)
                    password = "123456"
                    isTermsAndViewChecked = true
                }
            Text("To start sleeping healthy again")
                .font(.albertSans(.regular, size: 16))
                .foregroundStyle(.gray)
        }
        .padding(.top, 20)
    }
    
    //MARK: Input Fields
    @ViewBuilder
    private var inputFields: some View {
        VStack(spacing: 16) {
            CustomTextField(text: $username, placeholder: "user name")
            CustomTextField(text: $email, placeholder: "e-mail")
            CustomTextField(text: $password, placeholder: "password", isSecure: true)
        }
    }
    
    //MARK: Terms and services
    @ViewBuilder
    private var termsAndView: some View {
        HStack(spacing: 8) {
            CustomCheckBoxView(isChecked: $isTermsAndViewChecked)
            
            Text("I agree to the Terms and Conditions and Privacy Policy.")
                .font(.albertSans(.regular, size: 14))
                .onTapGesture {
                    isSheetingPresented = true
                }
        }
        .frame(width: UIScreen.screenWidth - 50 , height: 50, alignment: .leading)
    }

    
    //MARK: Sign Up Button
    @ViewBuilder
    private var signUpButton: some View {
        Button {
            Task {
                try await viewModel.signUp(username: username, email: email, password: password)
            }
        } label: {
            Text("Sign up")
                .font(.albertSans(.semibold, size: 16))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    //MARK: Social Buttons
    @ViewBuilder
    private var socialSignUpButtons: some View {
        VStack(spacing: 12) {
            appleSignInButton
            googleSignInButton
        }
    }
    
    @ViewBuilder
    private var appleSignInButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                viewModel.handleAppleSignInRequest(request)
            },
            onCompletion: { result in
                viewModel.handleAppleSignInCompletion(result)
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private var googleSignInButton: some View {
        Button(action: {
            viewModel.googleSignIn()
        }) {
            RoundedRectangle(cornerRadius:15)
                .fill(.black)
                .frame(width: UIScreen.screenWidth - 50 , height: 50)
                .overlay {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                }
        }
    }
}
