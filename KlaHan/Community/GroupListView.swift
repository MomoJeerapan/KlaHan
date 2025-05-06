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
    @State private var groups: [Group] = []
    @State private var invitations: [GroupInvitation] = []
    @State private var isPresented: Bool = false
    @State private var isInboxPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
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

            List(groups, id: \.subject) { group in
                NavigationLink(destination: GroupDetailView(groupId: group.id)) {
                    HStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 40, height: 40)
                        Text(group.subject)
                            .font(.headline)
                        Spacer()
                        Text("฿\(group.balance ?? 0, specifier: "%.2f")")
                            .foregroundColor(.gray)
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
                CreateGroupView()
                    .environmentObject(Model())
            }
        }
        .sheet(isPresented: $isInboxPresented) {
            NavigationStack {
                GroupInvitationInboxView()
            }
        }
    }

    func fetchUserGroups() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Groups")
            .whereField("members", arrayContains: currentUID)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.groups = docs.map { doc in
                    let data = doc.data()
                    return Group(
                        id: doc.documentID,
                        subject: data["subject"] as? String ?? "Untitled",
                        members: data["members"] as? [String] ?? [],
                        balance: data["balance"] as? Double
                    )
                }
            }
    }
}

struct GroupInvitation: Identifiable {
    let id: String
    let groupId: String
    let groupName: String
    let from: String
    let to: String
    let status: String
}
#Preview {
    GroupListView()
}
