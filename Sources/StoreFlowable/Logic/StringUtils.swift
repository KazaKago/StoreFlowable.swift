//
//  File.swift
//  
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

extension Optional where Wrapped == String {
    func isNilOrEmpty() -> Bool {
        guard let str = self else { return true }
        return str.isEmpty
    }

    func isNotNilOrEmpty() -> Bool {
        guard let str = self else { return false }
        return !str.isEmpty
    }
}
