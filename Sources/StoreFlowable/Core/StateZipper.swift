//
//  StateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

public extension State {

    /**
     * Combine multiple `State`.
     *
     * - parameter state2: The second `State` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `State` containing the combined data.
     */
    func zip<B, Z>(_ state2: State<B>, _ transform: (_ rawContent1: T, _ rawContent2: B) -> Z) -> State<Z> {
        switch self {
        case .fixed(let content):
            switch state2 {
            case .fixed(let otherContent):
                return .fixed(content: content.zip(otherContent, transform))
            case .loading(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .error(let otherContent, let otherRawError):
                return .error(content: content.zip(otherContent, transform), rawError: otherRawError)
            }
        case .loading(let content):
            switch state2 {
            case .fixed(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .loading(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .error(let otherContent, let rawError):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            }
        case .error(let content, let rawError):
            switch state2 {
            case .fixed(let otherContent):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            case .loading(let otherContent):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            case .error(let otherContent, _):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            }
        }
    }

    /**
     * Combine multiple `State`.
     *
     * - parameter state2: The second `State` to combine.
     * - parameter state3: The third `State` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `State` containing the combined data.
     */
    func zip<B, C, Z>(_ state2: State<B>, _ state3: State<C>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C) -> Z) -> State<Z> {
        zip(state2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(state3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
    }

    /**
     * Combine multiple `State`.
     *
     * - parameter state2: The second `State` to combine.
     * - parameter state3: The third `State` to combine.
     * - parameter state4: The fourth `State` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `State` containing the combined data.
     */
    func zip<B, C, D, Z>(_ state2: State<B>, _ state3: State<C>, _ state4: State<D>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D) -> Z) -> State<Z> {
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
     * Combine multiple `State`.
     *
     * - parameter state2: The second `State` to combine.
     * - parameter state3: The third `State` to combine.
     * - parameter state4: The fourth `State` to combine.
     * - parameter state5: The fifth `State` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `State` containing the combined data.
     */
    func zip<B, C, D, E, Z>(_ state2: State<B>, _ state3: State<C>, _ state4: State<D>, _ state5: State<E>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D, _ rawContent5: E) -> Z) -> State<Z> {
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
