//
//  ChangePassView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 8/5/2568 BE.


import SwiftUI

struct ChangePassView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var isPasswordChanged = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Change Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))
                    .padding(.top, 20)

                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    if newPassword != confirmPassword {
                        errorMessage = "New passwords do not match"
                    } else if newPassword.count < 6 {
                        errorMessage = "Password must be at least 6 characters"
                    } else {
                        errorMessage = ""
                        isPasswordChanged = true
                        // ใส่ logic เปลี่ยนรหัสผ่านที่นี่ เช่น update ใน Firebase
                        print("Password changed")
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Confirm")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationBarTitle("Change Password", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
//                Image(systemName: "chevron.left")
//                Text("Back")
            })
        }
    }
}

#Preview {
    ChangePassView()
}
