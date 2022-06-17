//
//  DataState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

enum DataState {
    case fixed(nextDataState: AdditionalDataState, prevDataState: AdditionalDataState)
    case loading(nextDataState: AdditionalDataState = .fixed, prevDataState: AdditionalDataState = .fixed)
    case error(nextDataState: AdditionalDataState = .fixed, prevDataState: AdditionalDataState = .fixed, rawError: Error)

    func nextDataState() -> AdditionalDataState {
        switch self {
        case .loading(let nextDataState, _): return nextDataState
        case .fixed(let nextDataState, _): return nextDataState
        case .error(let nextDataState, _, _): return nextDataState
        }
    }

    func prevDataState() -> AdditionalDataState {
        switch self {
        case .loading(_, let prevDataState): return prevDataState
        case .fixed(_, let prevDataState): return prevDataState
        case .error(_, let prevDataState, _): return prevDataState
        }
    }
}
