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
                    Image("Lion") // ใช้ชื่อรูปของคุณ
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
                leading:
                    NavigationLink(destination: TopUpView()) {
                        Text("Top Up")
                            .font(.headline)
                            .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))
                    },
                trailing:
                    NavigationLink(destination: InformationView()) {
                        Image("Lion") // ใช้โลโก้โปรไฟล์ของคุณ
                            .resizable()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }
}

#Preview {
    ProfileView()
}
