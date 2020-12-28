//
//  PagingStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PagingStoreFlowable {

    associatedtype KEY: Hashable
    associatedtype DATA

    func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never>

    func get(type: AsDataType) -> AnyPublisher<[DATA], Error>

    func validate() -> AnyPublisher<Void, Never>

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never>

    func requestAdditional(continueWhenError: Bool) -> AnyPublisher<Void, Never>

    func update(newData: [DATA]?) -> AnyPublisher<Void, Never>
}

public extension PagingStoreFlowable {

    func asFlow(forceRefresh: Bool = false) -> AnyPublisher<FlowableState<[DATA]>, Never> {
        asFlow(forceRefresh: forceRefresh)
    }

    func get(type: AsDataType = .mix) -> AnyPublisher<[DATA], Error> {
        get(type: type)
    }

    func refresh(clearCacheWhenFetchFails: Bool = true, continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        refresh(clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError)
    }

    func requestAdditional(continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        requestAdditional(continueWhenError: continueWhenError)
    }
}
