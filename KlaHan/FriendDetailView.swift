//
//  FriendDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

struct FriendDetailView: View {
    var name: String
    let transactions = [
        ("26 เม.ย.", "ซื้อข้าว", "฿150.00"),
        ("25 เม.ย.", "ค่ารถ", "฿80.00")
    ]

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)

            Text(name)
                .font(.title.bold())

            Text("THB → USD (Exchange Rate)")
                .font(.subheadline)
                .foregroundColor(.gray)

            TabView {
                ForEach(transactions, id: \.0) { item in
                    VStack {
                        Text("วันที่ \(item.0)")
                            .font(.headline)
                        Text(item.1)
                            .font(.title2)
                        Text(item.2)
                            .font(.title)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 160)

            Spacer()

            HStack(spacing: 12) {
                ForEach(["ยืมเงิน", "คืนเงิน", "แปลงเงิน", "Export Excel"], id: \.self) { action in
                    Button(action: {}) {
                        Text(action)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.bottom)
        }
        .padding(.top)
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
}
