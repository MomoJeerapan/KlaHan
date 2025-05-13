//
//  GroupDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupDetailView: View {
    let groupId: String
    let currentUID: String

    @State private var groupName: String = "Loading..."
    @State private var members: [UserIdentity] = []
    @State private var transactions: [ParsedItem] = []
    @State private var selectedMember: UserIdentity?

    var body: some View {
        VStack(spacing: 12) {
            memberScrollView

            TabView {
                ForEach(transactions.sorted(by: { $0.date > $1.date })) { item in
                    VStack {
                        Text(item.description).font(.headline)
                        Text("฿\(item.amount)").bold()
                        Text(formattedDate(item.date)).font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 160)

            Text("สรุปยอดคืนเงิน").font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(generateSummaryGrouped(), id: \.consumer.uid) { section in
                        Text("👤 \(section.consumer.name)").font(.subheadline)

                        ForEach(section.entries, id: \.self) { entry in
                            Text("→ จ่ายให้ \(entry.payer.name): ฿\(entry.amount, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Divider()
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            HStack(spacing: 12) {
                if let selected = selectedMember {
                    NavigationLink(
                        destination: PromptpayView(
                            payerName: "ฉัน",
                            receiverName: selected.name,
                            payerImage: Image(systemName: "person.circle.fill"),
                            receiverImage: Image(systemName: "person.circle.fill"),
                            context: .group(groupId: groupId, receiverUID: selected.uid)
                        )
                    ) {
                        Text("คืนเงินให้ \(selected.name)")
                            .padding()
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
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(groupName)
        .onAppear {
            fetchGroupInfo()
            fetchTransactions()
        }
    }

    private var memberScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(members, id: \.uid) { member in
                    VStack {
                        Circle()
                            .fill(selectedMember?.uid == member.uid ? Color.orange : Color.teal)
                            .frame(width: 60, height: 60)
                            .overlay(Text(String(member.name.prefix(1))).foregroundColor(.white))
                        Text(member.name).font(.caption)
                    }
                    .onTapGesture {
                        selectedMember = member
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func fetchGroupInfo() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            groupName = data["subject"] as? String ?? "Unnamed Group"
            let memberUIDs = data["members"] as? [String] ?? []

            let group = DispatchGroup()
            var result: [UserIdentity] = []

            for uid in memberUIDs {
                group.enter()
                db.collection("Users").document(uid).getDocument { doc, _ in
                    let name = doc?.data()?["Username"] as? String ?? "Unknown"
                    result.append(UserIdentity(uid: uid, name: name))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.members = result
            }
        }
    }

    private func fetchTransactions() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).collection("Transactions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, _ in
                self.transactions = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let ts = data["date"] as? Timestamp else { return nil }

                    let payerData = data["payer"] as? [String: String]
                    let consumersData = data["consumers"] as? [[String: String]]

                    return ParsedItem(
                        description: data["description"] as? String ?? "-",
                        amount: String(format: "%.2f", data["amount"] as? Double ?? 0),
                        date: ts.dateValue(),
                        payer: payerData.flatMap { dict in
                            guard let uid = dict["uid"], let name = dict["name"] else { return nil }
                            return UserIdentity(uid: uid, name: name)
                        },
                        consumers: consumersData?.compactMap {
                            guard let uid = $0["uid"], let name = $0["name"] else { return nil }
                            return UserIdentity(uid: uid, name: name)
                        } ?? [],
                        amountPerConsumer: data["amountPerConsumer"] as? Double
                    )
                } ?? []
            }
    }

    private func generateSummaryGrouped() -> [(consumer: UserIdentity, entries: [SummaryEntry])] {
        var summary: [SummaryEntry] = []

        for item in transactions {
            guard let payer = item.payer, let amount = item.amountPerConsumer else { continue }

            for consumer in item.consumers where consumer.uid != payer.uid {
                summary.append(SummaryEntry(consumer: consumer, payer: payer, amount: amount))
            }
        }

        let grouped = Dictionary(grouping: summary, by: \.consumer)

        return grouped.map { (consumer, entries) in
            (
                consumer: consumer,
                entries: Dictionary(grouping: entries, by: \.payer).map { (payer, list) in
                    SummaryEntry(consumer: consumer, payer: payer, amount: list.reduce(0) { $0 + $1.amount })
                }
            )
        }.sorted { $0.consumer.name < $1.consumer.name }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
