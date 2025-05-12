//
//  GroupListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GroupListView: View {
    @State private var groups: [Groups] = []
    @State private var myGroupDebts: [String: Double] = [:]
    @State private var isPresented = false
    @State private var isInboxPresented = false

    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Button(action: {
                    isInboxPresented = true
                }) {
                    HStack {
                        Image(systemName: "envelope.badge")
                        Text("Invitations")
                    }
                }

                Spacer()

                Button(action: {
                    isPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Create Group")
                    }
                }
            }
            .padding([.horizontal, .top])

            // List of groups
            List(groups, id: \.id) { group in
                let amountOwed = myGroupDebts[group.id] ?? 0.0

                NavigationLink(destination: GroupDetailView(groupId: group.id)) {
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

    // MARK: - Fetch Groups
    func fetchUserGroups() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Groups")
            .whereField("members", arrayContains: uid)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let fetchedGroups = docs.map { doc -> Groups in
                    let data = doc.data()
                    return Groups(
                        id: doc.documentID,
                        subject: data["subject"] as? String ?? "Untitled",
                        members: data["members"] as? [String] ?? [],
                        balance: nil
                    )
                }

                self.groups = fetchedGroups

                for group in fetchedGroups {
                    fetchMyDebtInGroup(groupId: group.id)
                }
            }
    }

    // MARK: - Fetch debt per group
    func fetchMyDebtInGroup(groupId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Groups").document(groupId)
            .collection("Balances")
            .whereField("consumer", isEqualTo: uid)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                let total = docs.reduce(0.0) { result, doc in
                    let amount = doc.data()["amount"] as? Double ?? 0.0
                    return result + amount
                }

                DispatchQueue.main.async {
                    myGroupDebts[groupId] = total
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
