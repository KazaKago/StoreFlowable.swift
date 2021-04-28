//
//  StateContent.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import Foundation

/**
 * This enum that indicates existing or not existing of data.
 *
 * - T: Types of data to be included.
 */
public enum StateContent<T> {
    /**
     * Data is exists.
     *
     * - rawContent: Included raw content.
     */
    case exist(rawContent: T)
    /**
     * Data does not exist.
     */
    case notExist

    /**
     * Provides callbacks existing or not existing data.
     * Same as `switch stateContent { ... }`.
     *
     * - parameter onExist: Callback for `Exist`.
     * - parameter onNotExist: Callback for `NotExist`.
     * - returns: Can return a value of any type.
     */
    public func doAction<V>(onExist: (_ rawContent: T) -> V, onNotExist: () -> V) -> V {
        switch self {
        case .exist(let rawContent):
            return onExist(rawContent)
        case .notExist:
            return onNotExist()
        }
    }

    /**
     * Create `StateContent` based on optional data.
     *
     * - parameter rawContent: Raw entity of data.
     * - returns: Created `StateContent`.
     */
    static func wrap(rawContent: T?) -> StateContent<T> {
        if let rawContent = rawContent {
            return .exist(rawContent: rawContent)
        } else {
            return .notExist
        }
    }
}
