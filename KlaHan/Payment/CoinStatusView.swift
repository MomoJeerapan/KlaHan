//
//  CoinStatusView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 8/5/2568 BE.
//

import SwiftUI

struct CoinStatusView: View {
    let coinBalance: Int
    let usedCoins: Int
    let topUpHistory: [(date: String, amount: Int, coins: Int)]

    var totalTHB: Int {
        topUpHistory.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("เหรียญของฉัน 💰")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top)

                VStack(spacing: 16) {
                    coinCard(title: "เหรียญที่มีอยู่", value: "\(coinBalance)", icon: "bitcoinsign.circle.fill", color: .yellow)
                    coinCard(title: "ใช้ไปแล้ว", value: "\(usedCoins)", icon: "minus.circle.fill", color: .red)
                    coinCard(title: "เติมเงินรวม", value: "\(totalTHB) บาท", icon: "banknote.fill", color: .green)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("ประวัติการเติม")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    if topUpHistory.isEmpty {
                        Text("ยังไม่มีประวัติการเติมเหรียญ")
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    } else {
                        ForEach(topUpHistory, id: \.date) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("วันที่ \(item.date)")
                                        .font(.headline)
                                    Text("เติม \(item.amount) บาท • ได้ \(item.coins) Coin")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "creditcard.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.15), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("สถานะเหรียญ")
        .navigationBarTitleDisplayMode(.inline)
    }

    func coinCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(12)
                .background(color)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.title)
                    .bold()
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    NavigationView {
        CoinStatusView(
            coinBalance: 120,
            usedCoins: 25,
            topUpHistory: [
                ("2025-05-08", 500, 60),
                ("2025-05-07", 300, 35),
                ("2025-05-06", 100, 10)
            ]
        )
    }
}
