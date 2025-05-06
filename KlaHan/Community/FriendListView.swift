//
//  FriendListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct FriendListView: View {
    
    @State private var isNavigatingToAddFriend = false
    @State private var friends: [FriendModel] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isNavigatingToAddFriend = true
            }) {
                Text("Add friend")
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            
            List(friends) { friend in
                NavigationLink(destination: FriendDetailView(friendID: friend.name)) {
                    HStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 40, height: 40)
                        Text(friend.name)
                            .font(.headline)
                        Spacer()
                        Text("฿\(friend.balance, specifier: "%.2f")")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
            .onAppear {
                fetchFriends()
            }
        }
    }
    func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("Users").document(currentUserID).getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let friendIDs = data["friends"] as? [String] else {
                print("❌ No friend list found.")
                return
            }

            var fetchedFriends: [FriendModel] = []
            let group = DispatchGroup()

            for uid in friendIDs {
                group.enter()
                db.collection("Users").document(uid).getDocument { friendSnap, _ in
                    let username = friendSnap?.data()?["Username"] as? String ?? "Unknown"
                    // สมมติว่า balance มาจากที่อื่น ใส่เป็น 0 ไปก่อน
                    let friend = FriendModel(id: uid, name: username, balance: 0)
                    fetchedFriends.append(friend)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.friends = fetchedFriends
            }
        }
    }

}

struct FriendModel: Identifiable {
        let id: String       // UID ของเพื่อน
        let name: String     // Username ของเพื่อน
        let balance: Double  // เช่น จำนวนเงินที่เกี่ยวข้อง ถ้ามี
}
#Preview {
    FriendListView()
}
