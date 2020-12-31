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

    func publish(forceRefresh: Bool) -> AnyPublisher<State<DATA>, Never>

    func get(type: AsDataType) -> AnyPublisher<DATA, Error>

    func validate() -> AnyPublisher<Void, Never>

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never>

    func update(newData: DATA?) -> AnyPublisher<Void, Never>
}

public extension StoreFlowable {

    func publish(forceRefresh: Bool = false) -> AnyPublisher<State<DATA>, Never> {
        publish(forceRefresh: forceRefresh)
    }

    func get(type: AsDataType = .mix) -> AnyPublisher<DATA, Error> {
        get(type: type)
    }

    func refresh(clearCacheWhenFetchFails: Bool = true, continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        refresh(clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError)
    }
}
