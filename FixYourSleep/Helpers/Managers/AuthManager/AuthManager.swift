//
//  AuthManager.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 5.12.2024.
//

import Observation
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import CryptoKit
import FirebaseCore

protocol AuthManagerProtocol {
    func getCurrentUser() async throws -> User
    func signInAnonymously() async throws
    func signOut() async throws
    func mailSignUp(mail: String, password: String) async throws
    func mailSignIn(mail: String, password: String) async throws
    func googleOauth() async throws -> GIDGoogleUser?
    func appleAuth(_ appleIdCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> AuthDataResult?
    func changeEmail(newEmail: String, password: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func resetPassword(forEmail email: String) async throws
    func randomNonceString(length: Int) -> String
    func sha256(_ input: String) -> String
}

enum AuthState {
    case authenticated
    case signedIn
    case signedOut
}

class AuthManager: AuthManagerProtocol {
    // MARK: Sıgn In Anonymously
    func signInAnonymously() async throws {
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            throw error
        }
    }
    
    // MARK: Sign Out
    func signOut() async throws {
        if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                throw error
            }
        }
    }
    
    // MARK: Authenticate User
    // takes AuthCredential to check if we have an authenticated user
    private func authenticateUser(credentials: AuthCredential) async throws {
        if Auth.auth().currentUser != nil {
            // we have user
          _ =  try await authLink(credentials: credentials)
        } else {
            // we don't have anonim authenticated
            _ = try await authSignIn(credentials: credentials)
        }
    }
    
    // MARK: Auth Sign In - with credentials
    private func authSignIn(credentials: AuthCredential) async throws {
        do {
             try await Auth.auth().signIn(with: credentials)
        } catch {
            throw error
        }
    }
    
    // MARK: Auth Link
    private func authLink(credentials: AuthCredential) async throws -> AuthDataResult? {
        do {
            guard let user = Auth.auth().currentUser else { return nil}
            let result = try await user.link(with: credentials)
            return result
        } catch {
            // print(FirebaseAuthError.failedToLink(error: error.localizedDescription))
            throw error
        }
    }
    
    // MARK: Update User name
    private func updateUserName(for user: User) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
            // current display name is not empty dont override
        } else {
            let displayName = user.providerData.first?.displayName
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            do {
                try await changeRequest.commitChanges()
            } catch {
                //  print(FirebaseAuthError.failedToUpdateUserName(error: error.localizedDescription))
            }
        }
    }
    
    // MARK: Mail SignUp
    func mailSignUp(mail: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: mail, password: password)
    }
    
    // MARK: Mail SignIn
    public func mailSignIn(mail: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: mail, password: password)
    }
    
    //MARK: Google sign in
    @MainActor
    func googleOauth() async throws -> GIDGoogleUser? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase clientID found")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            fatalError("There is no root view controller!")
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "AuthManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch ID token"])
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            //updateStatus(user: authResult.user)
            print("Successfully signed in with Google")
            print("User email: \(authResult.user.email ?? "No email")")
            return user
        } catch let error as NSError {
            if error.domain == AuthErrorDomain {
                switch error.code {
                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                    // Handle the case where the account exists with a different credential
                    print("An account already exists with a different credential")
                case AuthErrorCode.credentialAlreadyInUse.rawValue:
                    // Handle the case where the credential is already associated with a Firebase user account
                    print("This Google account is already linked to a Firebase user")
                default:
                    print("Other Firebase Auth error: \(error.localizedDescription)")
                }
            } else {
                print("Unexpected error: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
    // MARK: Change Email
    func changeEmail(newEmail: String, password: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where the user is not authenticated
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])
        }
        
        // Re-authenticate the user to confirm their identity
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: password)
        do {
            let authResult = try await currentUser.reauthenticate(with: credential)
            try await authResult.user.sendEmailVerification(beforeUpdatingEmail: newEmail)
            print("Email address changed successfully")
        } catch {
            // Handle errors
            print("Error changing email: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: Change Password
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where the user is not authenticated
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"])
        }
        
        // Re-authenticate the user to confirm their identity
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: currentPassword)
        do {
            let authResult = try await currentUser.reauthenticate(with: credential)
            try await authResult.user.updatePassword(to: newPassword)
            print("Password changed successfully")
        } catch {
            // Handle errors
            print("Error changing password: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: Reset Password
    func resetPassword(forEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Password reset email sent successfully")
        } catch {
            // Handle errors
            print("Error sending password reset email: \(error.localizedDescription)")
            throw error
        }
    }
    
    //MARK: Get current user
    func getCurrentUser() async throws -> User {
           guard let currentUser = Auth.auth().currentUser else {
               throw NSError(
                   domain: "AuthManager",
                   code: 401,
                   userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]
               )
           }
           return currentUser
       }
}

// MARK: - Apple Sign-In Implementation
extension AuthManager {
    @MainActor
    func appleAuth(_ appleIdCredential: ASAuthorizationAppleIDCredential, nonce: String?) async throws -> AuthDataResult? {
        guard let nonce = nonce else { throw NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."]) }
        
        guard let appleIDToken = appleIdCredential.identityToken else {
            throw NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data: \(appleIDToken.debugDescription)"])
        }
        
        // Initialize a Firebase credential using the ID token.
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        // Sign in with Firebase using the Apple credential
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            //updateStatus(user: authResult.user)
            return authResult
        } catch {
            throw error
        }
    }

    // MARK: Random Nonce String
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // MARK: SHA256
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
