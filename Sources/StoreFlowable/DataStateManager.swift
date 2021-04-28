//
//  DataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol DataStateManager {

    associatedtype KEY

    func loadState(key: KEY) -> DataState

    func saveState(key: KEY, state: DataState)
}
