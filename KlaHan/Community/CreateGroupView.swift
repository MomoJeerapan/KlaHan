//
//  CreateGroupView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 2/5/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct Friend: Identifiable {
    let id: String
    let name: String
}


struct CreateGroupView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: Model

    @State private var GroupSubject: String = ""
    @State private var friends: [Friend] = []
    @State private var selectedFriendIDs: Set<String> = []

    private var isFormValid: Bool {
        !GroupSubject.isEmptyOrWhitespace
    }

    private func fetchFriends() {
        model.fetchFriends { fetched in
            self.friends = fetched
        }
    }

    private func saveGroup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        // 1. ใส่เฉพาะผู้สร้าง
        let groupData: [String: Any] = [
            "subject": GroupSubject,
            "members": [uid],
            "createdAt": Timestamp()
        ]

        var docRef: DocumentReference? = nil
        docRef = db.collection("Groups").addDocument(data: groupData) { error in
            if let error = error {
                print("❌ Failed to create group: \(error.localizedDescription)")
            } else if let groupRef = docRef {
                print("✅ Group created: \(groupRef.documentID)")
                sendInvitations(groupId: groupRef.documentID)
                dismiss()
            }
        }
    }
    
    private func sendInvitations(groupId: String) {
        guard let fromUID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        for friendID in selectedFriendIDs {
            db.collection("GroupInvitations").addDocument(data: [
                "groupId": groupId,
                "groupName": GroupSubject,
                "from": fromUID,
                "to": friendID,
                "status": "pending",
                "timestamp": Timestamp()
            ]) { error in
                if let error = error {
                    print("❌ Failed to invite \(friendID): \(error.localizedDescription)")
                }
            }
        }
    }

    var body: some View {
        VStack {
            Text("Create Group")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))

            TextField("Group Name", text: $GroupSubject)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Text("Invite Friends")
                .font(.headline)
                .padding(.top)

            List(friends) { friend in
                HStack {
                    Text(friend.name)
                    Spacer()
                    Image(systemName: selectedFriendIDs.contains(friend.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.teal)
                        .onTapGesture {
                            if selectedFriendIDs.contains(friend.id) {
                                selectedFriendIDs.remove(friend.id)
                            } else {
                                selectedFriendIDs.insert(friend.id)
                            }
                        }
                }
            }
            .frame(height: 300)

            Spacer()
        }
        .padding()
        .onAppear(perform: fetchFriends)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Group").bold()
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    saveGroup()
                }
                .disabled(!isFormValid)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateGroupView()
            .environmentObject(Model())
    }
}

