//
//  SignInView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 4.12.2024.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var router: RouterManager
    @StateObject var viewModel: SignInViewModel
    @StateObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject private var userStateManager: UserStateManager
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            inputFields
            signInButton
            CustomDivider()
                .padding(.vertical, 8)
            socialSignInButtons
            Spacer()
        }
        
        .navigationBarBackButtonHidden()
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .background(.blackBg)
        .onChange(of: userStateManager.authState) { oldValue, newValue in
            print("Auth state changed from \(oldValue) to \(newValue)") // Add this debug print
            if newValue == .signedIn {
                Task { @MainActor in
                    router.navigateTo(to: .splash)
                }
            }
        }
        
    }
    
    // MARK: Header View
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
            
            Text("Welcome Back")
                .font(.albertSans(.semibold, size: 32))
            Text("Sign in to continue")
                .font(.albertSans(.regular, size: 16))
                .foregroundStyle(.gray)
        }
        .padding(.top, 20)
    }
    
    // MARK: Input Fields
    @ViewBuilder
    private var inputFields: some View {
        VStack(spacing: 16) {
            CustomTextField(text: $email, placeholder: "e-mail")
            CustomTextField(text: $password, placeholder: "password", isSecure: true)
            forgotPasswordButton
        }
    }
    
    // MARK: Sign In Button
    @ViewBuilder
    private var signInButton: some View {
        Button {
            // Sign in action
        } label: {
            Text("Sign in")
                .font(.albertSans(.semibold, size: 16))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    // MARK: Forgot Password Button
    @ViewBuilder
    private var forgotPasswordButton: some View {
        HStack {
            Spacer()
            Button {
                // Forgot password action
            } label: {
                Text("Forgot Password?")
                    .underline()
                    .font(.albertSans(.medium, size: 14))
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    //MARK: Social Buttons
    @ViewBuilder
    private var socialSignInButtons: some View {
        VStack(spacing: 12) {
            appleSignInButton
            googleSignInButton
        }
    }
    
    private var appleSignInButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                signUpViewModel.handleAppleSignInRequest(request)
            },
            onCompletion: { result in
                signUpViewModel.handleAppleSignInCompletion(result)
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(15)
    }
    
    private var googleSignInButton: some View {
        Button(action: {
            signUpViewModel.googleSignIn()
        }) {
            RoundedRectangle(cornerRadius:15)
                .fill(.black)
                .frame(width: UIScreen.screenWidth - 50, height: 50)
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
