//
//  TranscriptSelectionView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 12/5/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum SelectionMode: String, CaseIterable {
    case group = "กลุ่ม"
    case friend = "เพื่อน"
}

struct TranscriptSelectionView: View {
    @State private var items: [ParsedItem]
    @State private var mode: SelectionMode = .group

    // Group
    @State private var groups: [Groups] = []
    @State private var selectedGroupId: String = ""
    @State private var groupMembers: [UserIdentity] = []
    @State private var selectedGroupPayer: UserIdentity?

    // Friend
    @State private var friends: [UserIdentity] = []
    @State private var selectedFriend: UserIdentity?

    // Shared
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    init(transcriptText: String) {
        let lines = transcriptText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        _items = State(initialValue: lines.map { ParsedItem(description: $0, amount: "", date: Date()) })
    }

    var body: some View {
        VStack {
            Picker("โหมด", selection: $mode) {
                ForEach(SelectionMode.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if mode == .group {
                groupSelectionView
            } else {
                friendSelectionView
            }

            itemListView

            Button("เพิ่มรายการ") {
                if mode == .group {
                    handleGroupSave()
                } else {
                    handleFriendSave()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            NavigationLink(destination: HomeView(), isActive: $navigateToHome) { EmptyView() }
        }
        .padding()
        .onAppear {
            fetchGroups()
            fetchFriends()
        }
        .alert("แจ้งเตือน", isPresented: $showAlert) {
            Button("ตกลง", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Group UI
    var groupSelectionView: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(groups, id: \.id) { group in
                        VStack {
                            Circle()
                                .fill(selectedGroupId == group.id ? Color.orange : Color.teal.opacity(0.6))
                                .frame(width: 60, height: 60)
                                .overlay(Text(String(group.subject.prefix(1))).foregroundColor(.white))
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

            Picker("ผู้จ่าย", selection: $selectedGroupPayer) {
                Text("เลือกผู้จ่าย").tag(UserIdentity?.none)
                ForEach(groupMembers) { member in
                    Text(member.name).tag(Optional(member))
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
        }
    }

    // MARK: - Friend UI
    var friendSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("เลือกเพื่อน").font(.headline).padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(friends, id: \.uid) { friend in
                        VStack {
                            Circle()
                                .fill(selectedFriend?.uid == friend.uid ? Color.orange : Color.teal.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .overlay(Text(String(friend.name.prefix(1))).font(.title2).foregroundColor(.white))
                            Text(friend.name).font(.caption)
                        }
                        .onTapGesture {
                            selectedFriend = friend
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }


    // MARK: - Shared Item List
    var itemListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($items) { $item in
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(item.description, isOn: $item.isSelected)
                            .font(.body).bold()

                        TextField("จำนวนเงิน", text: $item.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        // MARK: - เลือกผู้บริโภค
                        Text("เลือกผู้บริโภค").font(.subheadline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            // ดึง current user
                            let currentUser = UserIdentity(
                                uid: Auth.auth().currentUser?.uid ?? "unknown",
                                name: "ฉัน"
                            )

                            // สร้างแหล่งข้อมูลผู้บริโภค
                            let consumersSource: [UserIdentity] = {
                                switch mode {
                                case .group:
                                    return groupMembers
                                case .friend:
                                    if let friend = selectedFriend {
                                        return [currentUser, friend] // ✅ เพิ่มตัวเองได้
                                    } else {
                                        return [currentUser] // ✅ ให้เลือกตัวเองอย่างเดียวก่อนเลือกเพื่อน
                                    }
                                }
                            }()

                            // แสดงผู้บริโภคที่เลือกได้
                            ForEach(consumersSource) { person in
                                let selected = item.consumers.contains(person)

                                Text(person.name)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(selected ? Color.orange : Color.teal.opacity(0.2))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        if selected {
                                            item.consumers.removeAll { $0 == person }
                                        } else {
                                            item.consumers.append(person)
                                        }
                                    }
                            }

                            if mode == .friend && selectedFriend == nil {
                                Text("กรุณาเลือกเพื่อนก่อน").foregroundColor(.gray)
                            }
                        }

                        Divider()
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Action: Save for Group
    private func handleGroupSave() {
        guard !selectedGroupId.isEmpty else {
            alertMessage = "กรุณาเลือกกลุ่ม"; showAlert = true; return
        }
        guard let payer = selectedGroupPayer else {
            alertMessage = "กรุณาเลือกผู้จ่าย"; showAlert = true; return
        }
        let validItems = items.filter { !$0.amount.isEmpty && !$0.consumers.isEmpty }
        guard !validItems.isEmpty else {
            alertMessage = "กรุณากรอกข้อมูลรายการ"; showAlert = true; return
        }

        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(selectedGroupId)

        for item in validItems {
            let total = Double(item.amount) ?? 0
            let perPerson = total / Double(item.consumers.count)

            let data: [String: Any] = [
                "description": item.description,
                "amount": total,
                "date": Timestamp(date: item.date),
                "payer": ["uid": payer.uid, "name": payer.name],
                "consumers": item.consumers.map { ["uid": $0.uid, "name": $0.name] },
                "amountPerConsumer": perPerson
            ]

            groupRef.collection("Transactions").addDocument(data: data)

            for consumer in item.consumers where consumer.uid != payer.uid {
                let balanceRef = groupRef.collection("Balances").document("\(consumer.uid)_to_\(payer.uid)")
                balanceRef.getDocument { snap, _ in
                    let current = snap?.data()?["amount"] as? Double ?? 0
                    balanceRef.setData([
                        "consumer": ["uid": consumer.uid, "name": consumer.name],
                        "payer": ["uid": payer.uid, "name": payer.name],
                        "amount": current + perPerson,
                        "isPaid": false
                    ])
                }
            }
        }

        navigateToHome = true
    }

    // MARK: - Action: Save for Friend
    private func handleFriendSave() {
        guard let friend = selectedFriend else {
            alertMessage = "กรุณาเลือกเพื่อน"; showAlert = true; return
        }
        let validItems = items.filter { !$0.amount.isEmpty }
        guard !validItems.isEmpty else {
            alertMessage = "กรุณากรอกรายการ"; showAlert = true; return
        }

        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid ?? ""
        let ref = db.collection("Users").document(uid).collection("FriendBalances")

        for item in validItems {
            let total = Double(item.amount) ?? 0
            let docId = "\(uid)_to_\(friend.uid)"

            ref.document(docId).getDocument { snap, _ in
                let current = snap?.data()?["amount"] as? Double ?? 0
                ref.document(docId).setData([
                    "from": uid,
                    "to": friend.uid,
                    "amount": current + total,
                    "isPaid": false
                ])
            }
        }

        navigateToHome = true
    }

    // MARK: - Firebase Helpers
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
        db.collection("Groups").document(groupId).getDocument { snap, _ in
            guard let uids = snap?.data()?["members"] as? [String] else { return }

            let group = DispatchGroup()
            var results: [UserIdentity] = []

            for uid in uids {
                group.enter()
                db.collection("Users").document(uid).getDocument { doc, _ in
                    let name = doc?.data()?["Username"] as? String ?? "Unknown"
                    results.append(UserIdentity(uid: uid, name: name))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.groupMembers = results
            }
        }
    }

    private func fetchFriends() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("Users").document(uid)
            .getDocument { snap, _ in
                let ids = snap?.data()?["friends"] as? [String] ?? []
                let group = DispatchGroup()
                var list: [UserIdentity] = []

                for fid in ids {
                    group.enter()
                    Firestore.firestore().collection("Users").document(fid).getDocument { doc, _ in
                        let name = doc?.data()?["Username"] as? String ?? "Unknown"
                        list.append(UserIdentity(uid: fid, name: name))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.friends = list
                }
            }
    }
}
