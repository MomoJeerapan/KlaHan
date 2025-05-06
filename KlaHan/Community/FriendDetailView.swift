//
//  FriendDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import Firebase

struct FriendDetailView: View {
    let friendID: String
    @State private var friendName: String = "Loading..."
    @State private var transactions: [(date: String, desc: String, amount: String)] = []

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)

            Text(friendName)
                .font(.title.bold())


            TabView {
                ForEach(transactions, id: \.date) { item in
                    VStack {
                        Text("วันที่ \(item.date)")
                            .font(.headline)
                        Text(item.desc)
                            .font(.title2)
                        Text(item.amount)
                            .font(.title)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
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
        .navigationTitle(friendName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchFriendInfo()
            fetchFriendTransactions()
        }
    }

    func fetchFriendInfo() {
        let db = Firestore.firestore()
        db.collection("Users").document(friendID).getDocument { snap, error in
            if let data = snap?.data(), let name = data["Username"] as? String {
                self.friendName = name
            }
        }
    }

    func fetchFriendTransactions() {
        let db = Firestore.firestore()
        db.collection("Users").document(friendID).collection("Transactions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.transactions = docs.map { doc in
                    let data = doc.data()
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    let dateString = formatter.string(from: date)

                    return (
                        date: dateString,
                        desc: data["description"] as? String ?? "-",
                        amount: "฿\(data["amount"] as? Double ?? 0)"
                    )
                }
            }
    }
}

