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

    func publish(forceRefresh: Bool) -> FlowableState<DATA>

    func getData(from: GettingFrom) -> AnyPublisher<DATA?, Never>

    func requireData(from: GettingFrom) -> AnyPublisher<DATA, Error>

    func validate() -> AnyPublisher<Void, Never>

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never>

    func update(newData: DATA?) -> AnyPublisher<Void, Never>
}

public extension StoreFlowable {

    func publish(forceRefresh: Bool = false) -> FlowableState<DATA> {
        publish(forceRefresh: forceRefresh)
    }

    func getData(from: GettingFrom = .mix) -> AnyPublisher<DATA?, Never> {
        getData(from: from)
    }

    func requireData(from: GettingFrom = .mix) -> AnyPublisher<DATA, Error> {
        requireData(from: from)
    }

    func refresh(clearCacheWhenFetchFails: Bool = true, continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        refresh(clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError)
    }
}
