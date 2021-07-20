//
//  DataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol DataStateManager {

    associatedtype KEY

    func load(key: KEY) -> DataState

    func save(key: KEY, state: DataState)
}
