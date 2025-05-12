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
    @State private var showAlert = false
    @State private var alertText = ""
    @State private var groups: [Groups] = []
    @State private var selectedGroupId: String = ""
    @State private var members: [String] = []
    @State private var payer: String?
    @State private var navigateToHome = false
    
    init(transcriptText: String) {
        let lines = transcriptText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        _items = State(initialValue: lines.map {
            ParsedItem(description: $0, amount: "", date: Date())
        })
    }
    
    var body: some View {
        VStack {
            // MARK: - เลือกกลุ่ม
            Text("เลือกกลุ่ม").font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(groups, id: \.id) { group in
                        VStack {
                            Circle()
                                .fill(selectedGroupId == group.id ? Color.orange : Color.teal.opacity(0.7))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(String(group.subject.prefix(1)))
                                        .font(.title2)
                                        .foregroundColor(.white)
                                )
                            Text(group.subject)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .onTapGesture {
                            selectedGroupId = group.id
                            fetchMembers(groupId: group.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: - เลือกผู้จ่าย
            if !members.isEmpty {
                VStack(alignment: .leading) {
                    Text("เลือกผู้จ่าย").font(.headline)
                    Picker("ผู้จ่าย", selection: $payer) {
                        Text("เลือกผู้จ่าย").tag(String?.none)
                        ForEach(members, id: \.self) { member in
                            Text(member).tag(Optional(member))
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)
            }
            
            // MARK: - รายการอาหาร
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("เลือกรายการอาหารและผู้บริโภค").font(.headline)
                    
                    ForEach($items) { $item in
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle(item.description, isOn: $item.isSelected)
                                .font(.body)
                                .bold()
                            
                            TextField("จำนวนเงิน", text: $item.amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            
                            Text("เลือกผู้บริโภค")
                                .font(.subheadline)
                            
                            // ✅ multi-select คนกิน
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                                ForEach(members, id: \.self) { member in
                                    let isSelected = item.consumers.contains(member)
                                    Text(member)
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(isSelected ? Color.orange : Color.teal.opacity(0.2))
                                        .foregroundColor(.primary)
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
                    
                    // MARK: - ปุ่มบันทึก
                    NavigationStack {
                        Button("เพิ่มรายการเข้า Group") {
                            guard !selectedGroupId.isEmpty else {
                                alertText = "กรุณาเลือกกลุ่ม"
                                showAlert = true
                                return
                            }
                            
                            guard let payer = payer else {
                                alertText = "กรุณาเลือกผู้จ่าย"
                                showAlert = true
                                return
                            }
                            
                            let validItems = items.filter { !$0.amount.isEmpty && !$0.consumers.isEmpty }
                            if validItems.isEmpty {
                                alertText = "กรุณากรอกจำนวนเงินและเลือกผู้บริโภคให้ครบทุกรายการ"
                                showAlert = true
                                return
                            }
                            
                            saveToGroup(items: validItems, toGroup: selectedGroupId, payer: payer)
                            navigateToHome = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .navigationDestination(isPresented: $navigateToHome) {
                            HomeView()
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear { fetchGroups() }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("แจ้งเตือน"), message: Text(alertText), dismissButton: .default(Text("ตกลง")))
        }
    }
    
    // MARK: - Firestore Methods
    
    func fetchGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("Groups")
            .whereField("members", arrayContains: uid)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    groups = docs.compactMap {
                        Groups(
                            id: $0.documentID,
                            subject: $0["subject"] as? String ?? "",
                            members: $0["members"] as? [String] ?? []
                        )
                    }
                }
            }
    }
    
    func fetchMembers(groupId: String) {
        let db = Firestore.firestore()
        db.collection("Groups").document(groupId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            let memberUIDs = data["members"] as? [String] ?? []
            
            let group = DispatchGroup()
            var names: [String] = []
            
            for uid in memberUIDs {
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
    }
    
    func saveToGroup(items: [ParsedItem], toGroup groupId: String, payer: String) {
        let db = Firestore.firestore()
        let groupRef = db.collection("Groups").document(groupId)
        
        var totalAmount: Double = 0.0
        
        for item in items {
            guard let total = Double(item.amount), !item.consumers.isEmpty else { continue }
            
            let perPersonAmount = total / Double(item.consumers.count)
            totalAmount += total
            
            let transactionData: [String: Any] = [
                "description": item.description,
                "amount": total,
                "date": Timestamp(date: item.date),
                "groupId": groupId,
                "payer": payer,
                "consumers": item.consumers,
                "amountPerConsumer": perPersonAmount // ✅ เพิ่มตรงนี้
            ]
            
            groupRef.collection("Transactions").addDocument(data: transactionData) { error in
                if let error = error {
                    print("❌ Error saving: \(error.localizedDescription)")
                } else {
                    print("✅ Transaction added with split: \(perPersonAmount) per person")
                }
            }
        }
        
        // อัปเดต balance รวม
        groupRef.getDocument { snapshot, error in
            let currentBalance = snapshot?.data()?["balance"] as? Double ?? 0.0
            let newBalance = currentBalance + totalAmount
            groupRef.updateData(["balance": newBalance])
        }
    }
}
