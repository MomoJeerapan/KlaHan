//
//  AuthManager.swift
//  KlaHan
//
//  Created by COSCI_LAB on 30/4/2568 BE.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


//struct AuthDataResultModel {
//    let uid: String
//    let email: String?
//    let photoUrl: String?
//
//    init(user: User) {
//        self.uid = user.uid
//        self.email = user.email
//        self.photoUrl = user.photoURL?.absoluteString
//    }
//}

final class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    func register(Email: String, password: String, Username: String, DateofBirth: Date, PhoneNum: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: Email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID not found."])))
                return
            }
            
            let db = Firestore.firestore()
            db.collection("Users").document(uid).setData([
                "Username": Username,
                "Email": Email,
                "DateofBirth": Timestamp(date: DateofBirth),
                "PhoneNum": PhoneNum,
                "uid": uid
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func login(Email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: Email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
