//
//  CustomizeView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct CustomizeView: View {
    @State private var selectedItem: Int? = nil
    @State private var showConfirmation = false
    @State private var coinBalance: Int = 500 // เริ่มต้นมีเหรียญเท่าไหร่ก็ใส่ตรงนี้เลย
    @State private var usedCoins: Int = 0

    let items = [
        ("ชุดที่ 1", 100),
        ("ชุดที่ 2", 100),
        ("ชุดที่ 3", 150),
        ("ชุดที่ 4", 150),
        ("ชุดที่ 5", 200),
        ("ชุดที่ 6", 300)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("เหรียญคงเหลือ: \(coinBalance) coins")
                    .font(.headline)
                    .padding(.top)

                Text("เลือกเสื้อผ้าให้ตัวการ์ตูน")
                    .font(.title2)
                    .bold()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                    ForEach(0..<items.count, id: \.self) { index in
                        let item = items[index]
                        VStack(spacing: 10) {
                            Rectangle()
                                .fill(Color.blue.opacity(0.4))
                                .frame(width: 100, height: 100)
                                .overlay(Text(item.0).foregroundColor(.white))

                            Text("ราคา \(item.1) coins")
                                .font(.subheadline)

                            Button(action: {
                                selectedItem = index
                                showConfirmation = true
                            }) {
                                Image(systemName: "cart.fill.badge.plus")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Customize")
        .alert(isPresented: $showConfirmation) {
            let item = items[selectedItem ?? 0]
            return Alert(
                title: Text("ยืนยันการซื้อ"),
                message: Text("คุณต้องการซื้อ \(item.0) ในราคา \(item.1) coins ใช่ไหม?"),
                primaryButton: .default(Text("ซื้อ")) {
                    if coinBalance >= item.1 {
                        coinBalance -= item.1
                        usedCoins += item.1
                        // ตรงนี้สามารถเพิ่ม logic เพิ่มชุดให้ user ได้ตามต้องการ
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    CustomizeView()
}
