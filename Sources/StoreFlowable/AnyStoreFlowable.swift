//
//  AnyStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/12.
//

import Foundation
import Combine

/**
 * Type erasure of `StoreFlowable`.
 */
public struct AnyStoreFlowable<KEY: Hashable, DATA>: StoreFlowable {

    public typealias KEY = KEY
    public typealias DATA = DATA

    private let _publish: (_ forceRefresh: Bool) -> LoadingStatePublisher<DATA>
    private let _getData: (_ from: GettingFrom) -> AnyPublisher<DATA?, Never>
    private let _requireData: (_ from: GettingFrom) -> AnyPublisher<DATA, Error>
    private let _validate: () -> AnyPublisher<Void, Never>
    private let _refresh: () -> AnyPublisher<Void, Never>
    private let _update: (_ newData: DATA?) -> AnyPublisher<Void, Never>

    init<INNER: StoreFlowable>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _publish = { forceRefresh in
            inner.publish(forceRefresh: forceRefresh)
        }
        _getData = { from in
            inner.getData(from: from)
        }
        _requireData = { from in
            inner.requireData(from: from)
        }
        _validate = {
            inner.validate()
        }
        _refresh = {
            inner.refresh()
        }
        _update = { newData in
            inner.update(newData: newData)
        }
    }

    public func publish(forceRefresh: Bool) -> LoadingStatePublisher<DATA> {
        _publish(forceRefresh)
    }

    public func getData(from: GettingFrom) -> AnyPublisher<DATA?, Never> {
        _getData(from)
    }

    public func requireData(from: GettingFrom) -> AnyPublisher<DATA, Error> {
        _requireData(from)
    }

    public func validate() -> AnyPublisher<Void, Never> {
        _validate()
    }

    public func refresh() -> AnyPublisher<Void, Never> {
        _refresh()
    }

    public func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        _update(newData)
    }
}
