//
//  FlowableStateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    func mapContent<A, Z>(_ transform: @escaping (A) -> Z) -> Publishers.Map<Self, FlowableState<Z>> where Self.Output == FlowableState<A> {
        map { input in
            switch input {
            case .fixed(let stateContent):
                return .fixed(stateContent: stateContent.mapContent(transform))
            case .loading(let stateContent):
                return .loading(stateContent: stateContent.mapContent(transform))
            case .error(let stateContent, let rawError):
                return .error(stateContent: stateContent.mapContent(transform), rawError: rawError)
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
