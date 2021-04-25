//
//  State.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import Foundation

/**
 * This enum that represents the state of the data.
 *
 * The following three states are shown.
 * - `Fixed` has not been processed.
 * - `Loading` is acquiring data.
 * - `Error` is an error when processing.
 *
 * The entity of the data is stored in `StateContent` separately from this `State`.
 *
 * - T: Types of data to be included.
 */
public enum State<T> {
    /**
     * No processing state.
     *
     * - content: Indicates the existing or not existing of data by `StateContent`.
     */
    case fixed(content: StateContent<T>)
    /**
     * Acquiring data state.
     *
     * - content: Indicates the existing or not existing of data by `StateContent`.
     */
    case loading(content: StateContent<T>)
    /**
     * An error when processing state.
     *
     * - content: Indicates the existing or not existing of data by `StateContent`.
     */
    case error(content: StateContent<T>, rawError: Error)

    /**
     * Indicates the existing or not existing of data by `StateContent`.
     */
    public var content: StateContent<T> {
        switch self {
        case .fixed(let content), .loading(let content), .error(let content, _):
            return content
        }
    }

    /**
     * Provides state-specific callbacks.
     * Same as `switch state { ... }`.
     *
     * - parameter onFixed: Callback for `Fixed`.
     * - parameter onLoading: Callback for `Loading`.
     * - parameter onError: Callback for `Error`.
     * - returns: Can return a value of any type.
     */
    public func doAction<V>(onFixed: () -> V, onLoading: () -> V, onError: (_ rawError: Error) -> V) -> V {
        switch self {
        case .fixed(_):
            return onFixed()
        case .loading(_):
            return onLoading()
        case .error(_, let rawError):
            return onError(rawError)
        }
    }
}
