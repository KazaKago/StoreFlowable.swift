//
//  AdditionalLoadingStateZipper.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

public extension AdditionalLoadingState {

    /**
     * Combine multiple `AdditionalLoadingState`.
     *
     * - parameter additionalState2: The second `AdditionalLoadingState` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `AdditionalLoadingState` containing the combined data.
     */
    func zip(_ additionalState2: AdditionalLoadingState) -> AdditionalLoadingState {
        switch self {
        case .fixed(let canRequestAdditionalData):
            switch additionalState2 {
            case .fixed(let otherCanRequestAdditionalData):
                return .fixed(canRequestAdditionalData: canRequestAdditionalData || otherCanRequestAdditionalData)
            case .loading:
                return .loading
            case .error(let otherRawError):
                return .error(rawError: otherRawError)
            }
        case .loading:
            switch additionalState2 {
            case .fixed(_):
                return .loading
            case .loading:
                return .loading
            case .error(let otherRawError):
                return .error(rawError: otherRawError)
            }
        case .error(let rawError):
            switch additionalState2 {
            case .fixed(_):
                return .error(rawError: rawError)
            case .loading:
                return .error(rawError: rawError)
            case .error(_):
                return .error(rawError: rawError)
            }
        }
    }
}
