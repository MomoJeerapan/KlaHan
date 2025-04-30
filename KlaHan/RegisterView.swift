//
//  RegisterView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 27/4/2568 BE.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var Email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var Username = ""
    @State private var DateofBirth = Date()
    @State private var PhoneNum = ""

    var body: some View {
        VStack(spacing: 45) {
            Text("Register")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))
            
            TextField("Username", text: $Username)
                           .padding()
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(8)
            
            TextField("Email", text: $Email)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            DatePicker("Date of Birth", selection: $DateofBirth, displayedComponents: .date)
                           .datePickerStyle(CompactDatePickerStyle())
                           .padding()
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(8)
                       
                       // Phone Number Field
                       TextField("Phone Number", text: $PhoneNum)
                           .keyboardType(.phonePad)
                           .padding()
                           .background(Color.gray.opacity(0.2))
                           .cornerRadius(8)
            
            Button(action: {
                AuthManager.shared.register(
                    Email: Email,
                    password: password,
                    Username: Username,
                    DateofBirth: DateofBirth,
                    PhoneNum: PhoneNum
                ) { result in
                    switch result {
                    case .success:
                        dismiss() // ปิดหน้าลงทะเบียน
                    case .failure(let error):
                        print("Registration failed: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0/255, green: 105/255, blue: 92/255))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    RegisterView()
}
