import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FriendListView: View {
    @State private var isNavigatingToAddFriend = false
    @State private var friends: [FriendModel] = []

    var body: some View {
        VStack(alignment: .leading) {
            Button("Add friend") {
                isNavigatingToAddFriend = true
            }
            .foregroundColor(.blue)
            .padding([.horizontal, .top])

            List(friends) { friend in
                NavigationLink(destination: FriendDetailView(friendID: friend.id)) {
                    HStack {
                        Circle().fill(Color.teal).frame(width: 40, height: 40)
                        Text(friend.name).font(.headline)
                        Spacer()
                        Text("\u{0e3f}\(abs(friend.balance), specifier: "%.2f")")
                            .foregroundColor(friend.balance >= 0 ? .red : .green)
                    }.padding(.vertical, 5)
                }
            }
            .onAppear { fetchFriends() }
            .sheet(isPresented: $isNavigatingToAddFriend) {
                NavigationStack { AddFriendView() }
            }
        }
    }

    func fetchFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("Users").document(currentUserID).getDocument { snapshot, _ in
            guard let data = snapshot?.data(), let friendIDs = data["friends"] as? [String] else { return }

            var fetchedFriends: [FriendModel] = []
            let group = DispatchGroup()

            for friendID in friendIDs {
                group.enter()

                db.collection("Users").document(friendID).getDocument { friendSnap, _ in
                    let friendName = friendSnap?.data()? ["Username"] as? String ?? String(friendID.prefix(6))

                    let docID = "\(currentUserID)_to_\(friendID)"
                    db.collection("Users")
                      .document(currentUserID)
                      .collection("FriendBalances")
                      .document(docID)
                      .getDocument { balanceSnap, _ in
                            let balance = balanceSnap?.data()? ["amount"] as? Double ?? 0.0
                            let friend = FriendModel(id: friendID, name: friendName, balance: balance)
                            fetchedFriends.append(friend)
                            group.leave()
                        }
                }
            }

            group.notify(queue: .main) {
                self.friends = fetchedFriends
            }
        }
    }
}

struct FriendModel: Identifiable {
    let id: String
    let name: String
    let balance: Double
}
