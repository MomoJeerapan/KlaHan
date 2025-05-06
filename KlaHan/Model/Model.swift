//
//  Model.swift
//  KlaHan
//
//  Created by COSCI_LAB on 2/5/2568 BE.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore




@MainActor
class Model: ObservableObject {
    
    
    @Published var groups: [Group] = []
    
    func saveGroup(group: Group, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        var docRef: DocumentReference? = nil
        docRef = db.collection("Groups")
            .addDocument(data: group.toDict()) { [weak self] error in
                if error != nil {
                    completion(error)
                } else {
                    if let docRef {
                        var newGroup = group
                        newGroup.documentId = docRef.documentID
                        self?.groups.append(newGroup)
                        completion(nil)
                    } else {
                        completion(nil)
                    }
                }
            }
    }

    func fetchFriends(completion: @escaping ([Friend]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(uid).getDocument { doc, _ in
            guard let data = doc?.data(),
                  let friendIDs = data["friends"] as? [String] else {
                completion([])
                return
            }

            var friends: [Friend] = []
            let group = DispatchGroup()
            
            for id in friendIDs {
                group.enter()
                Firestore.firestore().collection("Users").document(id).getDocument { friendDoc, _ in
                    let name = friendDoc?.data()?["Username"] as? String ?? "Unknown"
                    friends.append(Friend(id: id, name: name))
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(friends)
            }
        }
    }

    
}

