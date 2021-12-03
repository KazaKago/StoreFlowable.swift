//
//  DataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol DataStateManager {

    associatedtype PARAM

    func load(param: PARAM) -> DataState

    func save(param: PARAM, state: DataState)
}
