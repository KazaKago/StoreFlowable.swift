//
//  AnyStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/12.
//

import Foundation
import Combine

struct AnyStoreFlowable<KEY: Hashable, DATA>: StoreFlowable {

    typealias KEY = KEY
    typealias DATA = DATA

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

    func asFlow() -> AnyPublisher<State<DATA>, Error> {
        _asFlow()
    }

    func asFlow(forceRefresh: Bool) -> AnyPublisher<State<DATA>, Error> {
        _asFlowWithForceRefresh(forceRefresh)
    }

    func get() -> AnyPublisher<DATA, Error> {
        _get()
    }

    func get(type: AsDataType) -> AnyPublisher<DATA, Error> {
        _getWithType(type)
    }

    func validate() -> AnyPublisher<Void, Error> {
        _validate()
    }

    func request() -> AnyPublisher<Void, Error> {
        _request()
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Error> {
        _update(newData)
    }
}
