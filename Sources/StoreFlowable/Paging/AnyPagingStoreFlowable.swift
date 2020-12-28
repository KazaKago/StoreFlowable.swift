//
//  AnyPagingStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public struct AnyPagingStoreFlowable<KEY: Hashable, DATA>: PagingStoreFlowable {

    public typealias KEY = KEY
    public typealias DATA = DATA

    private let _asFlow: (_ forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never>
    private let _get: (_ type: AsDataType) -> AnyPublisher<[DATA], Error>
    private let _validate: () -> AnyPublisher<Void, Never>
    private let _refresh: (_ clearCacheWhenFetchFails: Bool, _ continueWhenError: Bool) -> AnyPublisher<Void, Never>
    private let _requestAdditional: (_ continueWhenError: Bool) -> AnyPublisher<Void, Never>
    private let _update: (_ newData: [DATA]?) -> AnyPublisher<Void, Never>

    init<INNER: PagingStoreFlowable>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _asFlow = { forceRefresh in
            inner.asFlow(forceRefresh: forceRefresh)
        }
        _get = { type in
            inner.get(type: type)
        }
        _validate = {
            inner.validate()
        }
        _refresh = { (clearCacheWhenFetchFails, continueWhenError) in
            inner.refresh(clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError)
        }
        _requestAdditional = { continueWhenError in
            inner.requestAdditional(continueWhenError: continueWhenError)
        }
        _update = { newData in
            inner.update(newData: newData)
        }
    }

    public func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never> {
        _asFlow(forceRefresh)
    }

    public func get(type: AsDataType) -> AnyPublisher<[DATA], Error> {
        _get(type)
    }

    public func validate() -> AnyPublisher<Void, Never> {
        _validate()
    }

    public func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        _refresh(clearCacheWhenFetchFails, continueWhenError)
    }

    public func requestAdditional(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        _requestAdditional(continueWhenError)
    }

    public func update(newData: [DATA]?) -> AnyPublisher<Void, Never> {
        _update(newData)
    }
}
