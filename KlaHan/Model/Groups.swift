//
//  Group.swift
//  KlaHan
//
//  Created by COSCI_LAB on 2/5/2568 BE.
//

import Foundation

struct Groups : Identifiable  {
    var id: String // documentID
    var subject: String
    var members: [String] = []
    var balance: Double? = nil
    var documentId: String?
    
    func toDict() -> [String: Any] {
        return [
            "subject": subject,
            "members": members,
            "balance": balance ?? 0.0
        ]
    }
}

