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
    @State private var transactions: [ParsedItem] = []
    @State private var selectedMember: String?
    
    var body: some View {
        VStack(spacing: 12) {
            
            // MARK: - Member Scroll View
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(members, id: \.self) { member in
                        VStack {
                            Circle()
                                .fill(selectedMember == member ? Color.orange : Color.teal.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .overlay(Text(String(member.prefix(1))).font(.title).foregroundColor(.white))
                            Text(member)
                                .font(.caption)
                        }
                        .onTapGesture {
                            selectedMember = member
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Text("THB → USD (Exchange Rate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // MARK: - Transactions TabView
            TabView {
                ForEach(transactions.sorted(by: { $0.date > $1.date })) { item in
                    VStack {
                        Text("วันที่ \(formattedDate(item.date))")
                            .font(.headline)
                        Text(item.description)
                            .font(.title2)
                        Text("฿\(item.amount)")
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
            Text("สรุปยอดคืนเงิน").font(.headline).padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(generateSummary(), id: \.self) { entry in
                        Text("• \(entry.consumer) คืนเงินให้ \(entry.payer): ฿\(entry.amount, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
            
            // MARK: - Action Buttons
            HStack(spacing: 12) {
                if let selected = selectedMember {
                    NavigationLink(
                        destination: PromptpayView(
                            payerName: "ฉัน",
                            receiverName: selected,
                            payerImage: Image(systemName: "person.circle.fill"),
                            receiverImage: Image(systemName: "person.circle.fill"),
                            context: .group(groupId: groupId)
                        )
                    ) {
                        Text("คืนเงินให้ \(selected)")
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Text("กรุณาเลือกสมาชิก")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                NavigationLink(destination: ExchangeView()) {
                    Text("แปลงเงิน")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
    
    // MARK: - Format Date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    
    // MARK: - Fetch Group Detail
    private func fetchGroupDetail() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            groupName = data["subject"] as? String ?? "Unnamed Group"
            
            let memberUIDs = data["members"] as? [String] ?? []
            fetchMemberUsernames(uids: memberUIDs)
        }
    }
    
    // MARK: - Fetch Member Usernames
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
    
    // MARK: - Fetch Transactions
    private func fetchTransactions() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).collection("Transactions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                
                self.transactions = docs.compactMap { doc in
                    let data = doc.data()
                    guard let timestamp = data["date"] as? Timestamp else { return nil }
                    
                    let amount = data["amount"] as? Double ?? 0
                    let consumers = data["consumers"] as? [String] ?? []
                    let payer = data["payer"] as? String
                    let amountPer = data["amountPerConsumer"] as? Double
                    
                    return ParsedItem(
                        description: data["description"] as? String ?? "-",
                        amount: String(format: "%.2f", amount),
                        date: timestamp.dateValue(),
                        payer: payer,
                        consumers: consumers,
                        amountPerConsumer: amountPer
                    )
                }
            }
    }
    
    private func generateSummary() -> [SummaryEntry] {
        var summary: [SummaryEntry] = []

        for item in transactions {
            guard let payer = item.payer,
                  let perAmount = item.amountPerConsumer else { continue }

            for consumer in item.consumers {
                if consumer != payer {
                    summary.append(SummaryEntry(consumer: consumer, payer: payer, amount: perAmount))
                }
            }
        }

        struct SummaryKey: Hashable {
            let consumer: String
            let payer: String
        }

        let combined = Dictionary(grouping: summary, by: { SummaryKey(consumer: $0.consumer, payer: $0.payer) })
            .map { (key, entries) in
                SummaryEntry(
                    consumer: key.consumer,
                    payer: key.payer,
                    amount: entries.map { $0.amount }.reduce(0, +)
                )
            }

        return combined.sorted { $0.consumer < $1.consumer }
    }

}

