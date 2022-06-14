//
//  DataStateMapper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

extension DataState {
    func toLoadingState<DATA>(content: DATA?, canNextRequest: Bool, canPrevRequest: Bool) -> LoadingState<DATA> {
        switch self {
        case .fixed(let nextDataState, let prevDataState):
            if let content = content {
                switch nextDataState {
                case .fixed:
                    let nextState = AdditionalLoadingState.fixed(canRequestAdditionalData: canNextRequest)
                    switch prevDataState {
                    case .fixed:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: canPrevRequest))
                    case .loading:
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                case .loading:
                    let nextState = AdditionalLoadingState.loading
                    switch prevDataState {
                    case .fixed:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: canPrevRequest))
                    case .loading:
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                case .error(let rawError):
                    let nextState = AdditionalLoadingState.error(rawError: rawError)
                    switch prevDataState {
                    case .fixed:
                        return .completed(content: content, next: nextState, prev: .fixed(canRequestAdditionalData: canPrevRequest))
                    case .loading:
                        return .completed(content: content, next: nextState, prev: .loading)
                    case .error(let rawError):
                        return .completed(content: content, next: nextState, prev: .error(rawError: rawError))
                    }
                }
            } else {
                return .loading(content: content)
            }
        case .loading:
            return .loading(content: content)
        case .error(_, _, let rawError):
            return .error(rawError: rawError)
        }
    }
}
