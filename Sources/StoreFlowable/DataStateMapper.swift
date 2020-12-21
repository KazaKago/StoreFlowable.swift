//
//  DataStateMapper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation

extension DataState {
    func mapState<DATA>(stateContent: StateContent<DATA>) -> State<DATA> {
        switch (self) {
        case .fixed:
            return .fixed(stateContent: stateContent)
        case .loading:
            return .loading(stateContent: stateContent)
        case .error(let rawError):
            return .error(stateContent: stateContent, rawError: rawError)
        }
    }
}
