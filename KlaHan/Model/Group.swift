//
//  Group.swift
//  KlaHan
//
//  Created by COSCI_LAB on 2/5/2568 BE.
//

import Foundation

struct Group : Identifiable  {
    var id: String // documentID
    var subject: String
    var members: [String]
    var documentId: String?
    var balance: Double?
    
    func toDict() -> [String: Any] {
        return [
            "subject": subject,
            "members": members
        ]
    }
}

