//
//  AnyPaginationStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation

/**
 * Type erasure of `PaginationStoreFlowable`.
 */
public struct AnyPaginationStoreFlowable<DATA>: PaginationStoreFlowable {

    public typealias DATA = DATA

    private let _publish: (_ forceRefresh: Bool) -> LoadingStatePublisher<DATA>
    private let _getData: (_ from: GettingFrom) async -> DATA?
    private let _requireData: (_ from: GettingFrom) async throws -> DATA
    private let _validate: () async -> ()
    private let _refresh: () async -> ()
    private let _requestNextData: (_ continueWhenError: Bool) async -> ()
    private let _update1: (_ newData: DATA?) async -> ()
    private let _update2: (_ newData: DATA?, _ nextKey: String?) async -> ()
    private let _clear: () async -> ()

    init<INNER: PaginationStoreFlowable>(_ inner: INNER) where INNER.DATA == DATA {
        _publish = { forceRefresh in
            inner.publish(forceRefresh: forceRefresh)
        }
        _getData = { from in
            await inner.getData(from: from)
        }
        _requireData = { from in
            try await inner.requireData(from: from)
        }
        _validate = {
            await inner.validate()
        }
        _refresh = {
            await inner.refresh()
        }
        _requestNextData = { continueWhenError in
            await inner.requestNextData(continueWhenError: continueWhenError)
        }
        _update1 = { newData in
            await inner.update(newData: newData)
        }
        _update2 = { newData, nextKey in
            await inner.update(newData: newData, nextKey: nextKey)
        }
        _clear = {
            await inner.clear()
        }
    }

    public func publish(forceRefresh: Bool) -> LoadingStatePublisher<DATA> {
        _publish(forceRefresh)
    }

    public func getData(from: GettingFrom) async -> DATA? {
        await _getData(from)
    }

    public func requireData(from: GettingFrom) async throws -> DATA {
        try await _requireData(from)
    }

    public func validate() async {
        await _validate()
    }

    public func refresh() async {
        await _refresh()
    }

    public func requestNextData(continueWhenError: Bool) async {
        await _requestNextData(continueWhenError)
    }

    public func update(newData: DATA?) async {
        await _update1(newData)
    }

    public func update(newData: DATA?, nextKey: String?) async {
        await _update2(newData, nextKey)
    }
    
    public func clear() async {
        await _clear()
    }
}
