//
//  String+Extensions.swift
//  KlaHan
//
//  Created by COSCI_LAB on 2/5/2568 BE.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
