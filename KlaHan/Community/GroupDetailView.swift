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
    let currentUID: String
    
    @State private var groupName: String = "Loading..."
    @State private var members: [UserIdentity] = []
    @State private var unpaidBalances: [SummaryEntry] = []
    @State private var paidBalances: [SummaryEntry] = []
    @State private var selectedMember: UserIdentity?
    @State private var balanceEntries: [SummaryEntry] = []

    
    var body: some View {
        VStack(spacing: 12) {
            memberScrollView
            // ⏳ ค้างชำระ
                Text("สรุปยอดคืนเงิน (ยังไม่จ่าย)").font(.headline).padding(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(unpaidBalances, id: \.self) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("• \(entry.consumer.name) คืนให้กับ \(entry.payer.name)")
                                        .font(.subheadline)
                                    Text("จำนวน: ฿\(entry.amount, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("❌") // แสดงว่ายังไม่จ่าย
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }

                // ✅ ชำระแล้ว
                Text("ประวัติการชำระ (จ่ายแล้ว)").font(.headline).padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(paidBalances, id: \.self) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("• \(entry.consumer.name) → \(entry.payer.name)")
                                    .font(.subheadline)
                                Text("จำนวน: ฿\(entry.amount, specifier: "%.2f")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("✅") // แสดงว่าชำระแล้ว
                                .foregroundColor(.green)
                                .font(.headline)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
            

            Spacer()
            
            if let selected = selectedMember {
                NavigationLink(destination: PromptpayView(
                    payerName: "ฉัน",
                    receiverName: selected.name,
                    payerImage: Image(systemName: "person.circle.fill"),
                    receiverImage: Image(systemName: "person.circle.fill"),
                    context: .group(groupId: groupId, receiverUID: selected.uid)
                )) {
                    Text("คืนเงินให้ \(selected.name)")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Text("กรุณาเลือกสมาชิก")
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
        .padding()
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchGroupName()
            fetchBalances()
        }
    }
    
    // MARK: - Views
    
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
    
    private func summarySection(entries: [SummaryEntry]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(entries, id: \.self) { entry in
                    HStack {
                        Text("• \(entry.consumer.name) → \(entry.payer.name): ฿\(entry.amount, specifier: "%.2f")")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if entry.isPaid == true {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    
    // MARK: - Firestore
    
    private func fetchGroupName() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            groupName = data["subject"] as? String ?? "Unnamed Group"
            let memberUIDs = data["members"] as? [String] ?? []
            fetchUserIdentities(from: memberUIDs)
        }
    }
    
    private func fetchUserIdentities(from uids: [String]) {
        let db = Firestore.firestore()
        var results: [UserIdentity] = []
        let group = DispatchGroup()
        
        for uid in uids {
            group.enter()
            db.collection("Users").document(uid).getDocument { doc, _ in
                let name = doc?.data()?["Username"] as? String ?? "Unknown"
                results.append(UserIdentity(uid: uid, name: name))
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.members = results
        }
    }
    
    private func fetchBalances() {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId)
            .collection("Balances")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                var unpaid: [SummaryEntry] = []
                var paid: [SummaryEntry] = []

                for doc in documents {
                    let data = doc.data()

                    guard
                        let consumerData = data["consumer"] as? [String: String],
                        let payerData = data["payer"] as? [String: String],
                        let consumerUID = consumerData["uid"],
                        let consumerName = consumerData["name"],
                        let payerUID = payerData["uid"],
                        let payerName = payerData["name"],
                        let amount = data["amount"] as? Double
                    else {
                        continue
                    }

                    let isPaid = data["isPaid"] as? Bool ?? false

                    let entry = SummaryEntry(
                        consumer: UserIdentity(uid: consumerUID, name: consumerName),
                        payer: UserIdentity(uid: payerUID, name: payerName),
                        amount: amount,
                        isPaid: isPaid
                    )

                    if isPaid {
                        paid.append(entry)
                    } else {
                        unpaid.append(entry)
                    }
                }

                DispatchQueue.main.async {
                    self.unpaidBalances = unpaid
                    self.paidBalances = paid
                }
            }
    }

}
