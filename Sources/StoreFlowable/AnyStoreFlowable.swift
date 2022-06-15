//
//  AnyStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/12.
//

/**
 * Type erasure of `StoreFlowable`.
 */
public struct AnyStoreFlowable<DATA>: StoreFlowable {

    public typealias DATA = DATA

    private let _publish: (_ forceRefresh: Bool) -> LoadingStateSequence<DATA>
    private let _getData: (_ from: GettingFrom) async -> DATA?
    private let _requireData: (_ from: GettingFrom) async throws -> DATA
    private let _validate: () async -> ()
    private let _refresh: () async -> ()
    private let _update: (_ newData: DATA?) async -> ()
    private let _clear: () async -> ()

    init<INNER: StoreFlowable>(_ inner: INNER) where INNER.DATA == DATA {
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
        _update = { newData in
            await inner.update(newData: newData)
        }
        _clear = {
            await inner.clear()
        }
    }

    public func publish(forceRefresh: Bool) -> LoadingStateSequence<DATA> {
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

    public func update(newData: DATA?) async {
        await _update(newData)
    }
    
    public func clear() async {
        await _clear()
    }
}
