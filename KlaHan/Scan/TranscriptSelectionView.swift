//
//  TranscriptSelectionView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 12/5/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TranscriptSelectionView: View {
    @State private var items: [ParsedItem]
    @State private var groups: [Groups] = []
    @State private var selectedGroupId: String = ""
    @State private var members: [UserIdentity] = []
    @State private var selectedPayer: UserIdentity?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    init(transcriptText: String) {
        let lines = transcriptText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        _items = State(initialValue: lines.map {
            ParsedItem(description: $0, amount: "", date: Date())
        })
    }

    var body: some View {
        VStack(spacing: 16) {
            groupSelector
            payerSelector
            itemList

            Button("เพิ่มรายการเข้า Group", action: saveButtonTapped)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

            NavigationLink(destination: HomeView(), isActive: $navigateToHome) { EmptyView() }
        }
        .padding()
        .onAppear(perform: fetchGroups)
        .alert("แจ้งเตือน", isPresented: $showAlert) {
            Button("ตกลง", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Group Selector
    var groupSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(groups, id: \.id) { group in
                    VStack {
                        Circle()
                            .fill(selectedGroupId == group.id ? Color.orange : Color.teal.opacity(0.7))
                            .frame(width: 60, height: 60)
                            .overlay(Text(String(group.subject.prefix(1))).font(.title2).foregroundColor(.white))
                        Text(group.subject).font(.caption)
                    }
                    .onTapGesture {
                        selectedGroupId = group.id
                        fetchMembers(groupId: group.id)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Payer Selector
    var payerSelector: some View {
        if members.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading) {
                Text("เลือกผู้จ่าย").font(.headline)
                Picker("ผู้จ่าย", selection: $selectedPayer) {
                    Text("เลือกผู้จ่าย").tag(UserIdentity?.none)
                    ForEach(members) { member in
                        Text(member.name).tag(Optional(member))
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal)
        )
    }

    // MARK: - Item List
    var itemList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($items) { $item in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(item.description, isOn: $item.isSelected)
                            .font(.body).bold()

                        TextField("จำนวนเงิน", text: $item.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        Text("เลือกผู้บริโภค").font(.subheadline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(members) { member in
                                let isSelected = item.consumers.contains(member)
                                Text(member.name)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(isSelected ? Color.orange : Color.teal.opacity(0.2))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        if isSelected {
                                            item.consumers.removeAll { $0 == member }
                                        } else {
                                            item.consumers.append(member)
                                        }
                                    }
                            }
                        }
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Actions
    private func saveButtonTapped() {
        guard !selectedGroupId.isEmpty else {
            alertMessage = "กรุณาเลือกกลุ่ม"; showAlert = true; return
        }
        guard let payer = selectedPayer else {
            alertMessage = "กรุณาเลือกผู้จ่าย"; showAlert = true; return
        }

        let validItems = items.filter { !$0.amount.isEmpty && !$0.consumers.isEmpty }
        guard !validItems.isEmpty else {
            alertMessage = "กรุณากรอกข้อมูลให้ครบถ้วน"; showAlert = true; return
        }

        saveToGroup(items: validItems, toGroup: selectedGroupId, payer: payer)
        navigateToHome = true
    }

    // MARK: - Firebase
    private func fetchGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Groups")
            .whereField("members", arrayContains: uid)
            .getDocuments { snapshot, _ in
                self.groups = snapshot?.documents.compactMap {
                    Groups(id: $0.documentID, subject: $0["subject"] as? String ?? "", members: $0["members"] as? [String] ?? [])
                } ?? []
            }
    }

    private func fetchMembers(groupId: String) {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            let uids = data["members"] as? [String] ?? []

            let group = DispatchGroup()
            var fetchedMembers: [UserIdentity] = []

            for uid in uids {
                group.enter()
                db.collection("Users").document(uid).getDocument { doc, _ in
                    let name = doc?.data()?["Username"] as? String ?? "Unknown"
                    fetchedMembers.append(UserIdentity(uid: uid, name: name))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.members = fetchedMembers
            }
        }
    }

    private func saveToGroup(items: [ParsedItem], toGroup groupId: String, payer: UserIdentity) {
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(groupId)

        var totalAmount: Double = 0.0

        for item in items {
            guard let amount = Double(item.amount), !item.consumers.isEmpty else { continue }
            let perPersonAmount = amount / Double(item.consumers.count)
            totalAmount += amount

            let transaction: [String: Any] = [
                "description": item.description,
                "amount": amount,
                "date": Timestamp(date: item.date),
                "payer": ["uid": payer.uid, "name": payer.name],
                "consumers": item.consumers.map { ["uid": $0.uid, "name": $0.name] },
                "amountPerConsumer": perPersonAmount
            ]

            groupRef.collection("Transactions").addDocument(data: transaction)

            for consumer in item.consumers where consumer.uid != payer.uid {
                let balanceRef = groupRef.collection("Balances").document("\(consumer.uid)_to_\(payer.uid)")

                balanceRef.getDocument { snapshot, _ in
                    let current = snapshot?.data()?["amount"] as? Double ?? 0.0
                    let newAmount = current + perPersonAmount
                    balanceRef.setData([
                        "consumer": ["uid": consumer.uid, "name": consumer.name],
                        "payer": ["uid": payer.uid, "name": payer.name],
                        "amount": newAmount
                    ])
                }
            }
        }

        groupRef.getDocument { snap, _ in
            let currentBalance = snap?.data()?["balance"] as? Double ?? 0.0
            groupRef.updateData(["balance": currentBalance + totalAmount])
        }
    }
}
