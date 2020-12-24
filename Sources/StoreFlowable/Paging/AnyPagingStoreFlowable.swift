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

    private let _asFlow: () -> AnyPublisher<FlowableState<[DATA]>, Never>
    private let _asFlowWithForceRefresh: (_ forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never>
    private let _get: () -> AnyPublisher<[DATA], Error>
    private let _getWithType: (_ type: AsDataType) -> AnyPublisher<[DATA], Error>
    private let _validate: () -> AnyPublisher<Void, Never>
    private let _request: () -> AnyPublisher<Void, Never>
    private let _requestAdditional: () -> AnyPublisher<Void, Never>
    private let _requestAdditionalWithFetchAtError: (_ fetchAtError: Bool) -> AnyPublisher<Void, Never>
    private let _update: (_ newData: [DATA]?) -> AnyPublisher<Void, Never>

    init<INNER: PagingStoreFlowable>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
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
        _requestAdditional = {
            inner.requestAdditional()
        }
        _requestAdditionalWithFetchAtError = { fetchOnError in
            inner.requestAdditional(fetchAtError: fetchOnError)
        }
        _update = { newData in
            inner.update(newData: newData)
        }
    }

    public func asFlow() -> AnyPublisher<FlowableState<[DATA]>, Never> {
        _asFlow()
    }

    public func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never> {
        _asFlowWithForceRefresh(forceRefresh)
    }

    public func get() -> AnyPublisher<[DATA], Error> {
        _get()
    }

    public func get(type: AsDataType) -> AnyPublisher<[DATA], Error> {
        _getWithType(type)
    }

    public func validate() -> AnyPublisher<Void, Never> {
        _validate()
    }

    public func request() -> AnyPublisher<Void, Never> {
        _request()
    }

    public func requestAdditional() -> AnyPublisher<Void, Never> {
        _requestAdditional()
    }

    public func requestAdditional(fetchAtError: Bool) -> AnyPublisher<Void, Never> {
        _requestAdditionalWithFetchAtError(fetchAtError)
    }

    public func update(newData: [DATA]?) -> AnyPublisher<Void, Never> {
        _update(newData)
    }
}
