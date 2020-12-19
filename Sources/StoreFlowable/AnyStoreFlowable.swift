//
//  AnyStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/12.
//

import Foundation
import Combine

public struct AnyStoreFlowable<KEY: Hashable, DATA>: StoreFlowable {

    public typealias KEY = KEY
    public typealias DATA = DATA

    private let _asFlow: () -> AnyPublisher<State<DATA>, Error>
    private let _asFlowWithForceRefresh: (_ forceRefresh: Bool) -> AnyPublisher<State<DATA>, Error>
    private let _get: () -> AnyPublisher<DATA, Error>
    private let _getWithType: (_ type: AsDataType) -> AnyPublisher<DATA, Error>
    private let _validate: () -> AnyPublisher<Void, Error>
    private let _request: () -> AnyPublisher<Void, Error>
    private let _update: (_ newData: DATA?) -> AnyPublisher<Void, Error>

    init<INNER: StoreFlowable>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _asFlow = {
            inner.asFlow()
        }
        _asFlowWithForceRefresh = { forceRefresh in
            inner.asFlow(forceRefresh: forceRefresh)
        }
        _get = {
            inner.get()
        }
        _getWithType = { type in
            inner.get(type: type)
        }
        _validate = {
            inner.validate()
        }
        _request = {
            inner.request()
        }
        _update = { newData in
            inner.update(newData: newData)
        }
    }

    public func asFlow() -> AnyPublisher<State<DATA>, Error> {
        _asFlow()
    }

    public func asFlow(forceRefresh: Bool) -> AnyPublisher<State<DATA>, Error> {
        _asFlowWithForceRefresh(forceRefresh)
    }

    public func get() -> AnyPublisher<DATA, Error> {
        _get()
    }

    public func get(type: AsDataType) -> AnyPublisher<DATA, Error> {
        _getWithType(type)
    }

    public func validate() -> AnyPublisher<Void, Error> {
        _validate()
    }

    public func request() -> AnyPublisher<Void, Error> {
        _request()
    }

    public func update(newData: DATA?) -> AnyPublisher<Void, Error> {
        _update(newData)
    }
}
