//
//  GroupListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupListView: View {
    @State private var groups: [Groups] = []
        @State private var myGroupDebts: [String: Double] = [:]
        @State private var isPresented = false
        @State private var isInboxPresented = false
        @State private var refreshTrigger = false  // เพิ่ม trigger

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        isInboxPresented = true
                    } label: {
                        Label("Invitations", systemImage: "envelope.badge")
                    }

                    Spacer()

                    Button {
                        isPresented = true
                    } label: {
                        Label("Create Group", systemImage: "plus.circle")
                    }
                }
                .padding([.horizontal, .top])

                List(groups, id: \.id) { group in
                    let groupId = group.id
                    let subject = group.subject
                    let amountOwed = myGroupDebts[groupId] ?? 0.0
                    let currentUID = Auth.auth().currentUser?.uid ?? ""

                    NavigationLink(
                        destination: GroupDetailView(groupId: groupId, currentUID: currentUID)
                    ) {
                        HStack {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 40, height: 40)
                            Text(subject)
                                .font(.headline)
                            Spacer()
                            Text("฿\(amountOwed, specifier: "%.2f")")
                                .foregroundColor(amountOwed == 0 ? .green : .red)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onAppear(perform: fetchUserGroups)
                .onChange(of: refreshTrigger) { _ in
                    fetchUserGroups()
                }
                .onReceive(NotificationCenter.default.publisher(for: .didSettleGroupDebt)) { _ in
                    refreshTrigger.toggle()
                }
            }
            .navigationTitle("Groups")
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    CreateGroupView().environmentObject(Model())
                }
            }
            .sheet(isPresented: $isInboxPresented) {
                NavigationStack {
                    GroupInvitationInboxView()
                }
            }
        }

    // MARK: - Firestore
    func fetchUserGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Groups")
            .whereField("members", arrayContains: uid)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let fetchedGroups = docs.map { doc in
                    Groups(
                        id: doc.documentID,
                        subject: doc["subject"] as? String ?? "Unnamed",
                        members: doc["members"] as? [String] ?? []
                    )
                }

                self.groups = fetchedGroups

                for group in fetchedGroups {
                    fetchMyDebtInGroup(groupId: group.id) // ← เรียกตรงนี้
                }
            }
    }


    func fetchMyDebtInGroup(groupId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("Groups").document(groupId)
            .collection("Balances")
            .whereField("consumer.uid", isEqualTo: uid)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                var totalOwed: Double = 0

                for doc in docs {
                    let amount = doc.data()["amount"] as? Double ?? 0.0
                    totalOwed += amount
                }

                DispatchQueue.main.async {
                    self.myGroupDebts[groupId] = totalOwed
                }
            }
    }

}


// MARK: - Model


    // MARK: - Model
    struct GroupInvitation: Identifiable {
        let id: String
        let groupId: String
        let groupName: String
        let from: String
        let to: String
        let status: String
        let Header: String
    }

#Preview {
    GroupListView()
}
