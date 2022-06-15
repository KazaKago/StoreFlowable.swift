//
//  DataStateFlowAccessor.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import AsyncExtensions

protocol DataStateFlowAccessor {

    func getFlow() -> AnyAsyncSequence<DataState>
}
