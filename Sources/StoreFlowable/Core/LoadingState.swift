//
//  LoadingState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

/**
 * This enum that represents the state of the data.
 *
 * The following three states are shown.
 * - `loading` is acquiring data.
 * - `completed` has not been processed.
 * - `error` is an error when processing.
 *
 * - T: Types of data to be included.
 */
public enum LoadingState<T> {
    /**
     * When data fetch is processing.
     *
     * - parameter content: Indicates the existing or not existing of data.
     */
    case loading(content: T?)
    /**
     * When data fetch is successful.
     *
     * - parameter content: Raw data.
     */
    case completed(content: T, next: AdditionalLoadingState, prev: AdditionalLoadingState)
    /**
     * When data fetch is failure.
     *
     * - parameter exception: Occurred exception.
     */
    case error(rawError: Error)

    /**
     * Provides state-specific callbacks.
     * Same as `switch state { ... }`.
     *
     * - parameter onLoading: Callback for `loading`.
     * - parameter onCompleted: Callback for `completed`.
     * - parameter onError: Callback for `error`.
     * - returns: Can return a value of any type.
     */
    public func doAction<V>(onLoading: (_ content: T?) -> V, onCompleted: (_ content: T, _ next: AdditionalLoadingState, _ prev: AdditionalLoadingState) -> V, onError: (_ rawError: Error) -> V) -> V {
        switch self {
        case .loading(let content):
            return onLoading(content)
        case .completed(let content, let next, let prev):
            return onCompleted(content, next, prev)
        case .error(let rawError):
            return onError(rawError)
        }
    }
}
