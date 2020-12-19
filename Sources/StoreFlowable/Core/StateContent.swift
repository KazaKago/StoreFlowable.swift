//
//  StateContent.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import Foundation

public enum StateContent<T> {
    case exist(rawContent: T)
    case notExist

    public func doAction<V>(onExist: (_ rawContent: T) -> V, onNotExist: () -> V) -> V {
        switch self {
        case .exist(let rawContent):
            return onExist(rawContent)
        case .notExist:
            return onNotExist()
        }
    }

    static func wrap(rawContent: T?) -> StateContent<T> {
        if let rawContent = rawContent {
            return .exist(rawContent: rawContent)
        } else {
            return .notExist
        }
    }
}
