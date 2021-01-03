//
//  FlowStateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    func mapContent<A, Z>(_ transform: @escaping (A) -> Z) -> Publishers.Map<Self, State<Z>> where Self.Output == State<A> {
        map { input in
            switch input {
            case .fixed(let content):
                return .fixed(content: content.mapContent(transform))
            case .loading(let content):
                return .loading(content: content.mapContent(transform))
            case .error(let content, let rawError):
                return .error(content: content.mapContent(transform), rawError: rawError)
            }
        }
    }
}

extension StateContent {

    func mapContent<Z>(_ transform: @escaping (T) -> Z) -> StateContent<Z> {
        switch self {
        case .exist(rawContent: let rawContent):
            return .exist(rawContent: transform(rawContent))
        case .notExist:
            return .notExist
        }
    }
}
