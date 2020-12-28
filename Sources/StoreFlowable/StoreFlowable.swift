//
//  StoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation
import Combine

public protocol StoreFlowable {

    associatedtype KEY: Hashable
    associatedtype DATA

    func asFlow() -> AnyPublisher<FlowableState<DATA>, Never>

    func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<DATA>, Never>

    func get() -> AnyPublisher<DATA, Error>

    func get(type: AsDataType) -> AnyPublisher<DATA, Error>

    func validate() -> AnyPublisher<Void, Never>

    func refresh() -> AnyPublisher<Void, Never>

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never>

    func update(newData: DATA?) -> AnyPublisher<Void, Never>
}
