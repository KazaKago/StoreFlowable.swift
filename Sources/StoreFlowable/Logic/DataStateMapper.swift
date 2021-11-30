//
//  DataStateMapper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation

extension DataState {
    func toLoadingState<DATA>(content: DATA?) -> LoadingState<DATA>? {
        switch self {
        case .fixed(let nextDataState, let prevDataState, let isInitial):
            if let content = content {
                switch nextDataState {
                case .fixed(_):
                    let nextState = AdditionalLoadingState.fixed(canRequestAdditionalData: true)
                    switch prevDataState {
                    case .fixed(_):
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: true))
                    case .fixedWithNoMoreAdditionalData:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: false))
                    case .loading(_):
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(_, let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                case .fixedWithNoMoreAdditionalData:
                    let nextState = AdditionalLoadingState.fixed(canRequestAdditionalData: false)
                    switch prevDataState {
                    case .fixed(_):
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: true))
                    case .fixedWithNoMoreAdditionalData:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: false))
                    case .loading(_):
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(_, let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                case .loading(_):
                    let nextState = AdditionalLoadingState.loading
                    switch prevDataState {
                    case .fixed(_):
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: true))
                    case .fixedWithNoMoreAdditionalData:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: false))
                    case .loading(_):
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(_, let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                case .error(_, let rawError):
                    let nextState = AdditionalLoadingState.error(rawError: rawError)
                    switch prevDataState {
                    case .fixed(_):
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: true))
                    case .fixedWithNoMoreAdditionalData:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: false))
                    case .loading(_):
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(_, let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                }
            } else if isInitial {
                return nil
            } else {
                return .loading(content: nil)
            }
        case .loading:
            return .loading(content: content)
        case .error(let rawError):
            return .error(rawError: rawError)
        }
    }
}
