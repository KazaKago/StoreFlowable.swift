//
//  File.swift
//  
//
//  Created by tamura_k on 2021/07/20.
//

extension Optional where Wrapped == String {
    func isNilOrEmpty() -> Bool {
        guard let str = self else { return true }
        return str.isEmpty
    }
}
