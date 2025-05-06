//
//  ProfileView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                // Profile title
                Text("Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))
                    .padding(.top, 40)

                // Avatar
                Button(action: {
                    print("Avatar tapped")
                }) {
                    Image("Lion") // เปลี่ยนเป็นชื่อรูปของคุณเอง
                        .resizable()
                        .frame(width: 290, height: 290)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 5)
                }
                .padding()

                // Customize button
                NavigationLink(destination: CustomizeView()) {
                    Text("Customize")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0/255, green: 105/255, blue: 92/255))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }

                Spacer()
            }
            .navigationBarItems(
                leading: Button(action: {
                    print("Settings tapped")
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                },
                trailing: Circle()
                    .fill(Color("DarkGreen"))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar) // ให้พื้นหลังขาว
        }
    }
}

#Preview {
    ProfileView()
}
