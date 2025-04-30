//
//  GroupDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

import SwiftUI

struct GroupDetailView: View {
    var groupName: String
    let members = ["Nene", "Tom", "Kate"]
    let transactions = [
        ("26 เม.ย.", "อาหารกลางวัน", "฿120.00"),
        ("24 เม.ย.", "ของขวัญ", "฿300.00")
    ]

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(members, id: \.self) { member in
                        VStack {
                            Circle()
                                .fill(Color.teal.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .overlay(Text(String(member.prefix(1))).font(.title).foregroundColor(.white))
                            Text(member)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal)
            }

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
                    .background(Color.orange.opacity(0.2))
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
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.bottom)
        }
        .padding(.top)
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    GroupDetailView(groupName: "Family Trip")
}
