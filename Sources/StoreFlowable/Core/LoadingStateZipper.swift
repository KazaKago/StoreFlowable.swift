//
//  LoadingStateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

public extension LoadingState {

    /**
     * Combine multiple `LoadingState`.
     *
     * - parameter state2: The second `LoadingState` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingState` containing the combined data.
     */
    func zip<B, Z>(_ state2: LoadingState<B>, _ transform: (_ rawContent1: T, _ rawContent2: B) -> Z) -> LoadingState<Z> {
        switch self {
        case .loading(let content):
            switch state2 {
            case .loading(let otherContent):
                if let content = content, let otherContent = otherContent {
                    return .loading(content: transform(content, otherContent))
                } else {
                    return .loading(content: nil)
                }
            case .completed(let otherContent, _, _):
                if let content = content {
                    return .loading(content: transform(content, otherContent))
                } else {
                    return .loading(content: nil)
                }
            case .error(let otherRawError):
                return .error(rawError: otherRawError)
            }
        case .completed(let content, let next, let prev):
            switch state2 {
            case .loading(let otherContent):
                if let otherContent = otherContent {
                    return .loading(content: transform(content, otherContent))
                } else {
                    return .loading(content: nil)
                }
            case .completed(let otherContent, let otherNext, let otherPrev):
                return .completed(content: transform(content, otherContent), next: next.zip(otherNext), prev: prev.zip(otherPrev))
            case .error(let otherRawError):
                return .error(rawError: otherRawError)
            }
        case .error(let rawError):
            switch state2 {
            case .loading(_):
                return .error(rawError: rawError)
            case .completed(_, _, _):
                return .error(rawError: rawError)
            case .error(_):
                return .error(rawError: rawError)
            }
        }
    }

    /**
     * Combine multiple `LoadingState`.
     *
     * - parameter state2: The second `LoadingState` to combine.
     * - parameter state3: The third `LoadingState` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingState` containing the combined data.
     */
    func zip<B, C, Z>(_ state2: LoadingState<B>, _ state3: LoadingState<C>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C) -> Z) -> LoadingState<Z> {
        zip(state2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(state3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
    }

    /**
     * Combine multiple `LoadingState`.
     *
     * - parameter state2: The second `LoadingState` to combine.
     * - parameter state3: The third `LoadingState` to combine.
     * - parameter state4: The fourth `LoadingState` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingState` containing the combined data.
     */
    func zip<B, C, D, Z>(_ state2: LoadingState<B>, _ state3: LoadingState<C>, _ state4: LoadingState<D>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D) -> Z) -> LoadingState<Z> {
        zip(state2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(state3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .zip(state4) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, other)
        }
    }

    /**
     * Combine multiple `LoadingState`.
     *
     * - parameter state2: The second `LoadingState` to combine.
     * - parameter state3: The third `LoadingState` to combine.
     * - parameter state4: The fourth `LoadingState` to combine.
     * - parameter state5: The fifth `LoadingState` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingState` containing the combined data.
     */
    func zip<B, C, D, E, Z>(_ state2: LoadingState<B>, _ state3: LoadingState<C>, _ state4: LoadingState<D>, _ state5: LoadingState<E>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D, _ rawContent5: E) -> Z) -> LoadingState<Z> {
        zip(state2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(state3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .zip(state4) { (rawContent, other) in
            (rawContent.0, rawContent.1, rawContent.2, other)
        }
        .zip(state5) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, rawContent.3, other)
        }
    }
}
