//
//  GroupDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GroupDetailView: View {
    let groupId: String

    @State private var groupName: String = "Loading..."
    @State private var members: [String] = []
    @State private var transactions: [(date: String, desc: String, amount: String)] = []

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
        .onAppear {
            fetchGroupDetail()
            fetchTransactions()
        }
    }

    private func fetchGroupDetail() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            groupName = data["subject"] as? String ?? "Unnamed Group"

            let memberUIDs = data["members"] as? [String] ?? []
            fetchMemberUsernames(uids: memberUIDs)
        }
    }

    private func fetchMemberUsernames(uids: [String]) {
        let db = Firestore.firestore()
        var names: [String] = []
        let group = DispatchGroup()

        for uid in uids {
            group.enter()
            db.collection("Users").document(uid).getDocument { doc, _ in
                let name = doc?.data()?["Username"] as? String ?? "Unknown"
                names.append(name)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.members = names
        }
    }

    private func fetchTransactions() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).collection("Transactions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                let formatter = DateFormatter()
                formatter.dateStyle = .medium

                self.transactions = docs.map { doc in
                    let data = doc.data()
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    return (
                        date: formatter.string(from: date),
                        desc: data["description"] as? String ?? "-",
                        amount: "฿\(data["amount"] as? Double ?? 0)"
                    )
                }
            }
    }
}

