//
//  FlowStateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import AsyncExtensions

public extension AsyncSequence {

    /**
     * Use when mapping raw data in `LoadingStateSequence`.
     *
     * - parameter transform: This callback that returns the result of transforming the data.
     * - returns: Return `LoadingStateSequence` containing the transformed data.
     */
    func mapContent<A, Z>(_ transform: @escaping (A) -> Z) -> AnyAsyncSequence<LoadingState<Z>> where Self.Element == LoadingState<A> {
        map { element in
            switch element {
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
        .eraseToAnyAsyncSequence()
    }
}
