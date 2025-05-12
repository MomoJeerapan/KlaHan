//
//  GroupInvitationInboxView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 7/5/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GroupInvitationInboxView: View {
    @Environment(\.dismiss) var dismiss
    @State private var invitations: [GroupInvitation] = []

    var body: some View {
        List(invitations) { invite in
            VStack(alignment: .leading) {
                Text("Group: \(invite.groupName)")
                    .font(.headline)

                Text("From: \(invite.Header)")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack {
                    Button("Accept") {
                        respondToGroupInvitation(invite, accept: true)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Reject") {
                        respondToGroupInvitation(invite, accept: false)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Invitations")
        .onAppear(perform: fetchGroupInvitations)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    func fetchGroupInvitations() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("GroupInvitations")
            .whereField("to", isEqualTo: uid)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                var fetchedInvitations: [GroupInvitation] = []
                let dispatchGroup = DispatchGroup()

                for doc in docs {
                    let data = doc.data()
                    let fromUID = data["from"] as? String ?? ""
                    let docId = doc.documentID

                    dispatchGroup.enter()
                    db.collection("Users").document(fromUID).getDocument { userSnapshot, _ in
                        let creatorName = userSnapshot?.data()?["Username"] as? String ?? "Unknown"

                        let invitation = GroupInvitation(
                            id: docId,
                            groupId: data["groupId"] as? String ?? "",
                            groupName: data["groupName"] as? String ?? "",
                            from: fromUID,
                            to: data["to"] as? String ?? "",
                            status: data["status"] as? String ?? "pending",
                            Header: creatorName // ✅ ใช้ชื่อผู้สร้างกลุ่ม
                        )

                        fetchedInvitations.append(invitation)
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.invitations = fetchedInvitations
                }
            }
    }

    func respondToGroupInvitation(_ invite: GroupInvitation, accept: Bool) {
        let db = Firestore.firestore()
        let inviteRef = db.collection("GroupInvitations").document(invite.id)
        let groupRef = db.collection("Groups").document(invite.groupId)
        
        let batch = db.batch()
        
        // อัปเดต status invitation
        batch.updateData(["status": accept ? "accepted" : "rejected"], forDocument: inviteRef)
        
        if accept {
            batch.updateData([
                "members": FieldValue.arrayUnion([invite.to])
            ], forDocument: groupRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("❌ \(error.localizedDescription)")
            } else {
                print("✅ Invitation \(accept ? "accepted" : "rejected")")
                fetchGroupInvitations()
            }
        }
    }
}
#Preview {
    GroupInvitationInboxView()
}
