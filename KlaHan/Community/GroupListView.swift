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

    var body: some View {
        VStack(alignment: .leading) {
            // MARK: - Header
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

            // MARK: - Group List
            List(groups, id: \.id) { group in
                let amountOwed = myGroupDebts[group.id] ?? 0.0
                let currentUID = Auth.auth().currentUser?.uid ?? ""

                NavigationLink(destination: GroupDetailView(groupId: group.id, currentUID: currentUID)) {
                    HStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 40, height: 40)
                        Text(group.subject)
                            .font(.headline)
                        Spacer()
                        Text("฿\(amountOwed, specifier: "%.2f")")
                            .foregroundColor(amountOwed == 0 ? .green : .red)
                    }
                    .padding(.vertical, 5)
                }
            }
            .onAppear {
                fetchUserGroups()
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

        Firestore.firestore().collection("Groups").document(groupId)
            .collection("Transactions")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                var totalOwed: Double = 0

                for doc in docs {
                    let data = doc.data()

                    guard
                        let payer = data["payer"] as? [String: Any],
                        let payerUID = payer["uid"] as? String,
                        let consumers = data["consumers"] as? [[String: Any]],
                        let amountPer = data["amountPerConsumer"] as? Double
                    else { continue }

                    if payerUID != uid,
                       consumers.contains(where: { $0["uid"] as? String == uid }) {
                        totalOwed += amountPer
                    }
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
