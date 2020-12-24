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

    func asFlow() -> AnyPublisher<FlowableState<[DATA]>, Never>

    func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never>

    func get() -> AnyPublisher<[DATA], Error>

    func get(type: AsDataType) -> AnyPublisher<[DATA], Error>

    func validate() -> AnyPublisher<Void, Never>

    func request() -> AnyPublisher<Void, Never>

    func requestAdditional() -> AnyPublisher<Void, Never>

    func requestAdditional(fetchAtError: Bool) -> AnyPublisher<Void, Never>

    func update(newData: [DATA]?) -> AnyPublisher<Void, Never>
}
