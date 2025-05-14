//
//  AddFriendView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 1/5/2568 BE.
//

import SwiftUI
import Contacts
import FirebaseAuth
import FirebaseFirestore

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab: Tab = .add
    @State private var searchText: String = ""
    @State private var foundUser: DocumentSnapshot?
    @State private var contacts: [CNContact] = []
    @State private var matchedUsers: [DocumentSnapshot] = []
    @State var friendRequests: [FriendRequestModel] = []

    let db = Firestore.firestore()
    let currentUserID: String = Auth.auth().currentUser?.uid ?? ""

    enum Tab {
        case add
        case requests
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Add Friend").tag(Tab.add)
                    Text("Requests").tag(Tab.requests)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == .add {
                    List {
                        Section(header: Text("Search by Username")) {
                            VStack(alignment: .leading) {
                                HStack {
                                    TextField("Enter Username", text: $searchText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button(action: {
                                        print("Searching for username: \(searchText)")
                                        searchUserByUsername(searchText)
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .padding(8)
                                            .background(Color.teal)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                }

                                if let user = foundUser {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(user["Username"] as? String ?? "Unknown")
                                        }
                                        Spacer()
                                        Button(action: {
                                            sendFriendRequest(to: user.documentID, toUsername: user["Username"] as? String ?? "")
                                        }) {
                                            Image(systemName: "person.badge.plus.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                } else if !searchText.isEmpty {
                                    Text("No user found with this username.")
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        Section(header: Text("From Contacts")) {
                            ForEach(matchedUsers, id: \.documentID) { user in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(user["Username"] as? String ?? "Unknown")
                                        Text(user["PhoneNum"] as? String ?? "")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: {
                                        sendFriendRequest(to: user.documentID, toUsername: user["Username"] as? String ?? "")
                                    }) {
                                        Image(systemName: "person.badge.plus.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .onAppear(perform: getContactList)

                } else {
                    List {
                        ScrollView {
                            VStack(alignment: .leading) {
                                Text("Request List")
                                    .font(.headline)
                                    .padding()

                                ForEach(friendRequests, id: \.id) { req in
                                    HStack {
                                        Text("From: \(req.fromUsername)")
                                        Spacer()
                                        Button("Accept") {
                                            respondToFriendRequest(req, accept: true)
                                        }
                                        .buttonStyle(.borderedProminent)

                                        Button("Reject") {
                                            respondToFriendRequest(req, accept: false)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.red)
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .onAppear(perform: fetchFriendRequests)
                    }
                }
            }
            .navigationTitle("Add Friend")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Contacts

    func getContactList() {
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            // ย้ายการเรียก fetchContacts ไปทำบน Background Thread
            DispatchQueue.global(qos: .userInitiated).async {
                fetchContacts(from: store)
            }
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, _ in
                if granted {
                    // ย้ายการเรียก fetchContacts ไปทำบน Background Thread หลังจากได้รับอนุญาต
                    DispatchQueue.global(qos: .userInitiated).async {
                        fetchContacts(from: store)
                    }
                }
            }
        default:
            break
        }
    }

    func fetchContacts(from store: CNContactStore) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        var contactPhones: [String] = []
        var fetchedContacts: [CNContact] = [] // สร้างตัวแปรเก็บ contacts ชั่วคราว

        try? store.enumerateContacts(with: request) { contact, _ in
            fetchedContacts.append(contact)
            for number in contact.phoneNumbers {
                let raw = number.value.stringValue
                contactPhones.append(normalizePhoneNumber(raw))
            }
        }

        // หลังจากดึงข้อมูลเสร็จแล้ว ให้กลับมาอัปเดต UI บน Main Thread
        DispatchQueue.main.async {
            contacts = fetchedContacts // อัปเดต state contacts บน Main Thread
            checkUsersInFirebase(phoneNumbers: contactPhones)
        }
    }

    func normalizePhoneNumber(_ number: String) -> String {
        number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    func checkUsersInFirebase(phoneNumbers: [String]) {
        matchedUsers.removeAll()
        for phone in phoneNumbers {
            db.collection("Users").whereField("PhoneNum", isEqualTo: phone).getDocuments { snapshot, _ in
                if let docs = snapshot?.documents {
                    // การอัปเดต matchedUsers ซึ่งเป็น @State ควรทำบน Main Thread
                    DispatchQueue.main.async {
                        matchedUsers.append(contentsOf: docs.filter { $0.documentID != currentUserID })
                    }
                }
            }
        }
    }

    // MARK: - Search and Requests

    func searchUserByUsername(_ username: String) {
        db.collection("Users")
            .whereField("Username", isEqualTo: username) // ค้นหาด้วยตัวพิมพ์เล็กทั้งหมด
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching user: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async { // อัปเดต foundUser บน Main Thread
                    if let doc = snapshot?.documents.first, doc.documentID != currentUserID {
                        foundUser = doc
                    } else {
                        foundUser = nil
                    }
                }
            }
    }

    func sendFriendRequest(to friendID: String, toUsername: String) {
        let ref = db.collection("FriendRequests").document()
        db.collection("Users").document(currentUserID).getDocument { snapshot, _ in
            let fromUsername = snapshot?.data()?["Username"] as? String ?? "unknown"
            ref.setData([
                "from": currentUserID,
                "fromUsername": fromUsername,
                "to": friendID,
                "toUsername": toUsername,
                "status": "pending",
                "timestamp": FieldValue.serverTimestamp()
            ]) { err in
                if let err = err {
                    print("❌ Error sending request: \(err.localizedDescription)")
                } else {
                    print("✅ Friend request sent.")
                }
            }
        }
    }

    func fetchFriendRequests() {
        let db = Firestore.firestore()

        db.collection("FriendRequests")
            .whereField("to", isEqualTo: currentUserID)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching friend requests: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No requests found.")
                    return
                }

                var tempRequests: [FriendRequestModel] = []

                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let from = data["from"] as? String ?? ""
                    let to = data["to"] as? String ?? ""
                    let status = data["status"] as? String ?? ""
                    let toUsername = data["toUsername"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()


                    group.enter()
                    // ดึงชื่อผู้ส่งจาก Users
                    db.collection("Users").document(from).getDocument { userSnap, _ in
                        let fromUsername = userSnap?.data()?["Username"] as? String ?? "Unknown"
                        let request = FriendRequestModel (
                            id: doc.documentID,
                            from: from,
                            fromUsername: fromUsername, to: to,
                            toUsername: toUsername, status: status,
                            timestamp: timestamp
                        )
                        tempRequests.append(request)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.friendRequests = tempRequests
                }
            }
    }


    func respondToFriendRequest(_ request: FriendRequestModel, accept: Bool) {
        let db = Firestore.firestore()
        let requestRef = db.collection("FriendRequests").document(request.id)

        if accept {
            let currentUserRef = db.collection("Users").document(request.to)
            let fromUserRef = db.collection("Users").document(request.from)

            let batch = db.batch()
            // 1. Update FriendRequest status
            batch.updateData([
                "status": "accepted"
            ], forDocument: requestRef)

            // 2. Add each other to friends list
            batch.updateData([
                "friends": FieldValue.arrayUnion([request.from])
            ], forDocument: currentUserRef)

            batch.updateData([
                "friends": FieldValue.arrayUnion([request.to])
            ], forDocument: fromUserRef)

            // 3. Commit
            batch.commit { error in
                if let error = error {
                    print("❌ Failed to accept friend request: \(error.localizedDescription)")
                } else {
                    print("✅ Friend request accepted and users are now friends.")
                    fetchFriendRequests() // รีโหลดรายการใหม่ถ้าจำเป็น
                }
            }
        } else {
            // ถ้าปฏิเสธ แค่เปลี่ยน status
            requestRef.updateData([
                "status": "rejected"
            ]) { error in
                if let error = error {
                    print("❌ Failed to reject: \(error.localizedDescription)")
                } else {
                    print("🚫 Request rejected")
                    fetchFriendRequests() // รีโหลดรายการใหม่ถ้าจำเป็น
                }
            }
        }
    }

}

// MARK: - Models

struct FriendRequestModel: Identifiable {
    let id: String
    let from: String
    let fromUsername: String
    let to: String
    let toUsername: String
    let status: String
    let timestamp: Date // หรือ Timestamp แล้วแต่การใช้งานของคุณ
}


#Preview {
    AddFriendView()
}
