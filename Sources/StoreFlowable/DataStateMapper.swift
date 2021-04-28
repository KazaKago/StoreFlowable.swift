//
//  DataStateMapper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation

extension DataState {
    func mapState<DATA>(content: StateContent<DATA>) -> State<DATA> {
        switch self {
        case .fixed:
            return .fixed(content: content)
        case .loading:
            return .loading(content: content)
        case .error(let rawError):
            return .error(content: content, rawError: rawError)
        }
    }
}
