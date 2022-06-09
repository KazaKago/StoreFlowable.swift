//
//  AnyDataStateFlowAccessor.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/08.
//

import Foundation
import AsyncExtensions

struct AnyDataStateFlowAccessor: DataStateFlowAccessor {

    private let _getFlow: () -> AnyAsyncSequence<DataState>

    init<INNER: DataStateFlowAccessor>(_ inner: INNER) {
        _getFlow = {
            inner.getFlow()
        }
    }
    
    init(getFlow: @escaping () -> AnyAsyncSequence<DataState>) {
        _getFlow = getFlow
    }

    func getFlow() -> AnyAsyncSequence<DataState> {
        _getFlow()
    }
}
