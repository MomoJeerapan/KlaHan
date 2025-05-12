//
//  TopUpView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct TopUpOption: Identifiable {
    let id = UUID()
    let amount: Int  // บาท
    let coins: Int   // Coin ที่ได้
}

struct TopUpView: View {
    @State private var coinBalance: Int = 0
    @State private var topUpHistory: [(date: String, amount: Int, coins: Int)] = []

    let topUpOptions: [TopUpOption] = [
        TopUpOption(amount: 50, coins: 5),
        TopUpOption(amount: 100, coins: 10),
        TopUpOption(amount: 200, coins: 22),
        TopUpOption(amount: 300, coins: 35),
        TopUpOption(amount: 500, coins: 60),
        TopUpOption(amount: 1000, coins: 130)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Top Up")
                        .font(.system(size: 34, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)

                    ForEach(topUpOptions) { option in
                        Button(action: {
                            coinBalance += option.coins
                            let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
                            topUpHistory.insert((date, option.amount, option.coins), at: 0)
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.orange)
                                    .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text("\(option.amount) บาท")
                                        .font(.headline)
                                    HStack {
                                        Image(systemName: "bitcoinsign.circle.fill")
                                            .foregroundColor(.yellow)
                                        Text("รับ \(option.coins) Coin")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "cart.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(
                                        colors: [Color.white, Color(.systemGray6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 3)
                            )
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: CoinStatusView(
                    coinBalance: coinBalance,
                    usedCoins: 0, // ยังไม่มีการใช้
                    topUpHistory: topUpHistory
                )) {
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                        Text("เหรียญของฉัน")
                    }
                }
            )
        }
    }
}

#Preview {
    TopUpView()
}

