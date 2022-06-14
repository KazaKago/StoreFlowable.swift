//
//  DataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

protocol DataStateManager {

    func load() -> DataState

    func save(state: DataState)
}
