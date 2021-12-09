//
//  DataState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

/**
 * Indicates the state of the data.
 *
 * This state is only used inside this library.
 */
public enum DataState {
    case fixed(nextDataState: AdditionalDataState, prevDataState: AdditionalDataState)
    case loading
    case error(rawError: Error)
    
    func nextDataStateOrNil() -> AdditionalDataState {
        switch self {
        case .fixed(let nextDataState, _): return nextDataState
        case .loading: return .fixedWithNoMoreAdditionalData
        case .error(_): return .fixedWithNoMoreAdditionalData
        }
    }

    func prevDataStateOrNil() -> AdditionalDataState {
        switch self {
        case .fixed(_, let prevDataState): return prevDataState
        case .loading: return .fixedWithNoMoreAdditionalData
        case .error(_): return .fixedWithNoMoreAdditionalData
        }
    }

    func nextKeyOrNil() -> String? {
        switch self {
        case .fixed(let nextDataState, _): return nextDataState.additionalRequestKeyOrNil()
        case .loading: return nil
        case .error(_): return nil
        }
    }

    func prevKeyOrNil() -> String? {
        switch self {
        case .fixed(_, let prevDataState): return prevDataState.additionalRequestKeyOrNil()
        case .loading: return nil
        case .error(_): return nil
        }
    }

}
