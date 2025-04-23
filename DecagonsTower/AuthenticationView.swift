//
//  AuthenticationView.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//

import SwiftUI

struct AuthenticationView: View {
    private enum AuthenticationType { case signIn, signUp }
    
    @State private var authenticationType: AuthenticationType = .signIn
    
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    
    @State private var alertTitle = ""
    @State private var isShowingAlert = false
    
    private var authenticationButtonTitle: String {
        switch authenticationType {
        case .signIn: "Sign In"
        case .signUp: "Sign Up"
        }
    }
    
    private var otherOptionPrompt: String {
        switch authenticationType {
        case .signIn: "Don't have an account?"
        case .signUp: "Already have an account?"
        }
    }
    
    private var otherOptionButtonTitle: String {
        switch authenticationType {
        case .signIn: "Sign Up"
        case .signUp: "Sign In"
        }
    }
    
    private var isAuthenticateButtonDisabled: Bool {
        switch authenticationType {
        case .signIn: email.isEmpty || password.isEmpty
        case .signUp: email.isEmpty || password.isEmpty || username.isEmpty
        }
    }
    
    
    var body: some View {
        VStack {
            Text("Decagon's Tower")
                .font(.largeTitle)
                .foregroundStyle(Color.white)
                .bold()
                .shadow(color: Color.red, radius: 15.0)
                .shadow(color: Color.red, radius: 15.0)
                .shadow(color: Color.red, radius: 15.0)
                .shadow(color: Color.red, radius: 15.0)
                .padding(.top, 50)
            
            TextField("Email", text: $email)
                .padding(5)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if authenticationType == .signUp {
                TextField("Username", text: $username)
                    .padding(5)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            SecureField("Password", text: $password)
                .padding(5)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
            
            Button(action: authenticatePressed) {
                Text(authenticationButtonTitle)
                    .foregroundStyle(Color.white)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 48.0 / 255.0, green: 80.0 / 255.0, blue: 35.0 / 255.0))
                    .clipShape(Capsule())
            }
            .disabled(isAuthenticateButtonDisabled)
            .padding(.top, 30)

            HStack(spacing: 10) {
                Text(otherOptionPrompt)
                
                Button(otherOptionButtonTitle, action: otherAuthenticationOptionPressed)
            }
            .font(.footnote)
            .padding(4)
            .padding(.horizontal, 8)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
                Image("map") // Change this to change background image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
        }
        .ignoresSafeArea(.all)
        .animation(.default, value: authenticationType)
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button("Ok", action: { isShowingAlert = false })
        }
    }
    
    private func authenticatePressed() {
        switch authenticationType {
        case .signIn: signIn()
        case .signUp: signUp()
        }
    }
    
    private func signUp() {
        Task {
            do {
                if try await Database.isUserNameAvailable(username: username) {
                    let firebaseUser = try await Authentication.signUp(email: email, password: password)
                    try Database.addUser(
                        id: firebaseUser.uid,
                        email: email,
                        username: username
                    )
                } else {
                    alertTitle = "Username already taken"
                    isShowingAlert = true
                }
            } catch {
                alertTitle = "Something went wrong"
                isShowingAlert = true
            }
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await Authentication.signIn(email: email, password: password)
            } catch {
                alertTitle = "Something went wrong"
                isShowingAlert = true
            }
        }
    }
    
    private func otherAuthenticationOptionPressed() {
        switch authenticationType {
        case .signIn: authenticationType = .signUp
        case .signUp: authenticationType = .signIn
        }
    }
}

#Preview {
    AuthenticationView()
}
