//
//  AnyTwoWayPaginationStoreFlowable.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation
import Combine

/**
 * Type erasure of `TwoWayPaginationStoreFlowable`.
 */
public struct AnyTwoWayPaginationStoreFlowable<DATA>: TwoWayPaginationStoreFlowable {

    public typealias DATA = DATA

    private let _publish: (_ forceRefresh: Bool) -> LoadingStatePublisher<DATA>
    private let _getData: (_ from: GettingFrom) -> AnyPublisher<DATA?, Never>
    private let _requireData: (_ from: GettingFrom) -> AnyPublisher<DATA, Error>
    private let _validate: () -> AnyPublisher<Void, Never>
    private let _refresh: () -> AnyPublisher<Void, Never>
    private let _requestNextData: (_ continueWhenError: Bool) -> AnyPublisher<Void, Never>
    private let _requestPrevData: (_ continueWhenError: Bool) -> AnyPublisher<Void, Never>
    private let _update1: (_ newData: DATA?) -> AnyPublisher<Void, Never>
    private let _update2: (_ newData: DATA?, _ nextKey: String?) -> AnyPublisher<Void, Never>
    private let _update3: (_ newData: DATA?, _ nextKey: String?, _ prevKey: String?) -> AnyPublisher<Void, Never>

    init<INNER: TwoWayPaginationStoreFlowable>(_ inner: INNER) where INNER.DATA == DATA {
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
        _requestNextData = { continueWhenError in
            inner.requestNextData(continueWhenError: continueWhenError)
        }
        _requestPrevData = { continueWhenError in
            inner.requestPrevData(continueWhenError: continueWhenError)
        }
        _update1 = { newData in
            inner.update(newData: newData)
        }
        _update2 = { newData, nextKey in
            inner.update(newData: newData, nextKey: nextKey)
        }
        _update3 = { newData, nextKey, prevKey in
            inner.update(newData: newData, nextKey: nextKey, prevKey: prevKey)
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

    public func requestNextData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        _requestNextData(continueWhenError)
    }
    
    public func requestPrevData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        _requestPrevData(continueWhenError)
    }

    public func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        _update1(newData)
    }

    public func update(newData: DATA?, nextKey: String?) -> AnyPublisher<Void, Never> {
        _update2(newData, nextKey)
    }

    public func update(newData: DATA?, nextKey: String?, prevKey: String?) -> AnyPublisher<Void, Never> {
        _update3(newData, nextKey, prevKey)
    }
}
