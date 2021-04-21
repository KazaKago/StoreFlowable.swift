//
//  State.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import Foundation

public enum State<T> {
    case fixed(content: StateContent<T>)
    case loading(content: StateContent<T>)
    case error(content: StateContent<T>, rawError: Error)

    public var content: StateContent<T> {
        switch self {
        case .fixed(let content), .loading(let content), .error(let content, _):
            return content
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
