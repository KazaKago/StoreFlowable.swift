//
//  AdditionalLoadingState.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

/**
 * This enum that represents the state of the additional pagination data.
 *
 * The following three states are shown.
 * - `fixed` has not been processed.
 * - `loading` is acquiring data.
 * - `error` is an error when processing.
 */
public enum AdditionalLoadingState {
    /**
     * No processing.
     *
     * - canRequestAdditionalData: Whether additional fetching is possible from the origin.
     */
    case fixed(canRequestAdditionalData: Bool)
    /**
     * when data fetch is processing.
     */
    case loading
    /**
     * when data fetch is failure.
     *
     * - rawError: Occurred exception.
     */
    case error(rawError: Error)

    /**
     * Provides state-specific callbacks.
     * Same as `switch state { ... }`.
     *
     * - parameter onFixed: Callback for `fixed`.
     * - parameter onLoading: Callback for `loading`.
     * - parameter onError: Callback for `error`.
     * - returns: Can return a value of any type.
     */
    public func doAction<V>(onFixed: (_ canRequestAdditionalData: Bool) -> V, onLoading: () -> V, onError: (_ rawError: Error) -> V) -> V {
        switch self {
        case .fixed(let canRequestAdditionalData):
            return onFixed(canRequestAdditionalData)
        case .loading:
            return onLoading()
        case .error(let rawError):
            return onError(rawError)
        }
    }
}
