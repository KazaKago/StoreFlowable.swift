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
            let content: StateContent<Z>
            switch input.content {
            case .exist(rawContent: let rawContent):
                content = .exist(rawContent: transform(rawContent))
            case .notExist:
                content = .notExist
            }
            switch input {
            case .fixed(_):
                return .fixed(content: content)
            case .loading(_):
                return .loading(content: content)
            case .error(_, let rawError):
                return .error(content: content, rawError: rawError)
            }
        }
    }
}
