//
//  PagingStoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine
import CombineAsync

struct PagingStoreFlowableImpl<KEY: Hashable, DATA>: PagingStoreFlowable {

    typealias KEY = KEY
    typealias DATA = DATA

    private let storeFlowableResponder: AnyPagingStoreFlowableResponder<KEY, DATA>
    private var dataSelector: PagingDataSelector<KEY, DATA>

    init(storeFlowableResponder: AnyPagingStoreFlowableResponder<KEY, DATA>) {
        self.storeFlowableResponder = storeFlowableResponder
        dataSelector = PagingDataSelector(
            key: storeFlowableResponder.key,
            dataStateManager: AnyDataStateManager(storeFlowableResponder.flowableDataStateManager),
            cacheDataManager: AnyPagingCacheDataManager(storeFlowableResponder),
            originDataManager: AnyPagingOriginDataManager(storeFlowableResponder),
            needRefresh: { data in storeFlowableResponder.needRefresh(data: data) }
        )
    }

    func asFlow() -> AnyPublisher<FlowableState<[DATA]>, Never> {
        asFlow(forceRefresh: false)
    }

    func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<[DATA]>, Never> {
        dataSelector.doStateAction(forceRefresh: forceRefresh, clearCache: true, fetchAtError: false, fetchAsync: true, additionalRequest: false)
            .flatMap { _ in
                storeFlowableResponder.flowableDataStateManager.getFlow(key: storeFlowableResponder.key)
            }
            .flatMap { dataState in
                dataSelector.load().map { data in
                    (dataState, data)
                }
            }
            .map { (dataState, data) in
                let stateContent = StateContent.wrap(rawContent: data)
                return dataState.mapState(stateContent: stateContent)
            }
            .eraseToAnyPublisher()
    }

    func get() -> AnyPublisher<[DATA], Error> {
        get(type: .mix)
    }

    func get(type: AsDataType) -> AnyPublisher<[DATA], Error> {
        async { yield in
            switch type {
            case .mix:
                try await(dataSelector.doStateAction(forceRefresh: false, clearCache: true, fetchAtError: false, fetchAsync: false, additionalRequest: false))
            case .fromOrigin:
                try await(dataSelector.doStateAction(forceRefresh: true, clearCache: true, fetchAtError: false, fetchAsync: false, additionalRequest: false))
            case .fromCache:
                //do nothing.
                break
            }
        }
        .flatMap {
            storeFlowableResponder.flowableDataStateManager.getFlow(key: storeFlowableResponder.key)
        }
        .flatMap { dataState in
            dataSelector.load().map { data in
                (dataState, data)
            }
        }
        .flatMap { (dataState, data) in
            async { yield in
                switch dataState {
                case .fixed:
                    if (data != nil && !(try! await(storeFlowableResponder.needRefresh(data: data!)))) {
                        yield(data!)
                    } else {
                        throw NoSuchElementError()
                    }
                case .loading:
                    // do nothing.
                    break
                case .error(let rawError):
                    if (data != nil && !(try! await(storeFlowableResponder.needRefresh(data: data!)))) {
                        yield(data!)
                    } else {
                        throw rawError
                    }
                }
            }
        }
        .first()
        .eraseToAnyPublisher()
    }

    func validate() -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: false, clearCache: true, fetchAtError: false, fetchAsync: false, additionalRequest: false)
    }

    func request() -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: true, clearCache: false, fetchAtError: true, fetchAsync: false, additionalRequest: false)
    }

    func requestAdditional() -> AnyPublisher<Void, Never> {
        requestAdditional(fetchAtError: true)
    }

    func requestAdditional(fetchAtError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: false, clearCache: false, fetchAtError: fetchAtError, fetchAsync: false, additionalRequest: true)
    }

    func update(newData: [DATA]?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData)
    }
}
