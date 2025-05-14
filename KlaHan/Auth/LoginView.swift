//
//  LoginView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 27/4/2568 BE.
//

import SwiftUI


struct LoginView: View {
    
    enum Route: Hashable {
        case home
    }
    
    @Binding var isLoggedIn: Bool
    @State private var Email = ""
    @State private var password = ""
    
    @State private var showingResetAlert = false
    @State private var resetMessage = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @ViewBuilder
    func socialLoginButton(backgroundColorName: String, imageName: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(text)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(backgroundColorName))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))

                VStack(spacing: 16) {
                    TextField("Email", text: $Email)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Button {
                    AuthManager.shared.login(Email: Email, password: password) { result in
                        switch result {
                        case .success:
                            isLoggedIn = true
                    
                        case .failure(let error):
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 1.0, green: 0.701, blue: 0.0))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // ปุ่ม Forgot Password
            Button(action: {
                //sendPasswordReset()
            }) {
                Text("Forgot Password?")
                    .font(.footnote)
                    .foregroundColor(Color.blue)
            }
            .padding(.top, -10)
            
            HStack {
                Text("Don't have an account?")
                NavigationLink("Register") {
                    RegisterView()
                }
            }
            .padding(.top, 20)
            
            Divider()
            VStack(spacing: 12) { // ลดระยะห่างระหว่างปุ่ม
                // Google Button
                socialLoginButton(backgroundColorName: "GoogleTone", imageName: "Google", text: "Sign in with Google") {
                    // isLoggedIn = true
                }
                
                // Apple Button
                socialLoginButton(backgroundColorName: "AppleTone", imageName: "Apple", text: "Sign in with Apple") {
                    // isLoggedIn = true
                }
                
                // Facebook Button
                socialLoginButton(backgroundColorName: "FacebookTone", imageName: "Facebook", text: "Sign in with Facebook") {
                    // isLoggedIn = true
                }
            }
            .padding(.horizontal, 24)
            .alert(isPresented: $showingResetAlert) {
                Alert(title: Text("Password Reset"), message: Text(resetMessage), dismissButton: .default(Text("OK")))
            }
        }
        
        //        private func sendPasswordReset() {
        //            guard !email.isEmpty else {
        //                resetMessage = "Please enter your email address first."
        //                showingResetAlert = true
        //                return
        //            }
        //
        //            guard let url = URL(string: "https://your-backend.com/api/forgot-password") else {
        //                resetMessage = "Invalid server URL."
        //                showingResetAlert = true
        //                return
        //            }
        //
        //            var request = URLRequest(url: url)
        //            request.httpMethod = "POST"
        //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //
        //            let body: [String: String] = ["email": email]
        //            request.httpBody = try? JSONEncoder().encode(body)
        //
        //            URLSession.shared.dataTask(with: request) { data, response, error in
        //                if let error = error {
        //                    DispatchQueue.main.async {
        //                        resetMessage = "Error: \(error.localizedDescription)"
        //                        showingResetAlert = true
        //                    }
        //                    return
        //                }
        //
        //                guard let data = data else {
        //                    DispatchQueue.main.async {
        //                        resetMessage = "No response from server."
        //                        showingResetAlert = true
        //                    }
        //                    return
        //                }
        //
        //                if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: data) {
        //                    DispatchQueue.main.async {
        //                        resetMessage = serverResponse.message
        //                        showingResetAlert = true
        //                    }
        //                } else {
        //                    DispatchQueue.main.async {
        //                        resetMessage = "Invalid response from server."
        //                        showingResetAlert = true
        //                    }
        //                }
        //            }.resume()
        //        }
    }
    
    struct ServerResponse: Decodable {
        let message: String
    }
}


#Preview {
    LoginView(isLoggedIn: .constant(false))
}
