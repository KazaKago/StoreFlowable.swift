//
//  FlowStateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    /**
     * Use when mapping raw data in `LoadingStatePublisher`.
     *
     * - parameter transform: This callback that returns the result of transforming the data.
     * - returns: Return `LoadingStatePublisher` containing the transformed data.
     */
    func mapContent<A, Z>(_ transform: @escaping (A) -> Z) -> Publishers.Map<Self, LoadingState<Z>> where Self.Output == LoadingState<A> {
        map { input in
            switch input {
            case .loading(let content):
                if let content = content {
                    return .loading(content: transform(content))
                } else {
                    return .loading(content: nil)
                }
            case .completed(let content, let next, let prev):
                return .completed(content: transform(content), next: next, prev: prev)
            case .error(let rawError):
                return .error(rawError: rawError)
            }
        }
    }
}
