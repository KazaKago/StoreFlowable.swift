//
//  FlowableState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import Foundation

public enum State<T> {
    case fixed(stateContent: StateContent<T>)
    case loading(stateContent: StateContent<T>)
    case error(stateContent: StateContent<T>, rawError: Error)

    public var stateContent: StateContent<T> {
        switch self {
        case .fixed(let stateContent), .loading(let stateContent), .error(let stateContent, _):
            return stateContent
        }
    }

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
