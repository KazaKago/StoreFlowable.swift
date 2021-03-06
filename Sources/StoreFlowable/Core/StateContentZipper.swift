//
//  StateContentZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

public extension StateContent {

    /**
     * Combine multiple `StateContent`.
     *
     * - parameter content2: The second `StateContent` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `StateContent` containing the combined data.
     */
    func zip<B, Z>(_ content2: StateContent<B>, _ transform: (_ rawContent1: T, _ rawContent2: B) -> Z) -> StateContent<Z> {
        switch self {
        case .exist(let rawContent):
            switch content2 {
            case .exist(let otherRawContent):
                return .exist(rawContent: transform(rawContent, otherRawContent))
            case .notExist:
                return .notExist
            }
        case .notExist:
            switch content2 {
            case .exist(_):
                return .notExist
            case .notExist:
                return .notExist
            }
        }
    }

    /**
     * Combine multiple `StateContent`.
     *
     * - parameter content2: The second `StateContent` to combine.
     * - parameter content3: The third `StateContent` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `StateContent` containing the combined data.
     */
    func zip<B, C, Z>(_ content2: StateContent<B>, _ content3: StateContent<C>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C) -> Z) -> StateContent<Z> {
        zip(content2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(content3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
    }

    /**
     * Combine multiple `StateContent`.
     *
     * - parameter content2: The second `StateContent` to combine.
     * - parameter content3: The third `StateContent` to combine.
     * - parameter content4: The fourth `StateContent` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `StateContent` containing the combined data.
     */
    func zip<B, C, D, Z>(_ content2: StateContent<B>, _ content3: StateContent<C>, _ content4: StateContent<D>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D) -> Z) -> StateContent<Z> {
        zip(content2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(content3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .zip(content4) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, other)
        }
    }

    /**
     * Combine multiple `StateContent`.
     *
     * - parameter content2: The second `StateContent` to combine.
     * - parameter content3: The third `StateContent` to combine.
     * - parameter content4: The fourth `StateContent` to combine.
     * - parameter content5: The fifth `StateContent` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `StateContent` containing the combined data.
     */
    func zip<B, C, D, E, Z>(_ content2: StateContent<B>, _ content3: StateContent<C>, _ content4: StateContent<D>, _ content5: StateContent<E>, _ transform: (_ rawContent1: T, _ rawContent2: B, _ rawContent3: C, _ rawContent4: D, _ rawContent5: E) -> Z) -> StateContent<Z> {
        zip(content2) { (rawContent, other) in
            (rawContent, other)
        }
        .zip(content3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .zip(content4) { (rawContent, other) in
            (rawContent.0, rawContent.1, rawContent.2, other)
        }
        .zip(content5) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, rawContent.3, other)
        }
    }
}
