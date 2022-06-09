//
//  DataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol DataStateManager {

    func load() -> DataState

    func save(state: DataState)
}
