//
//  StoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine
import CombineAsync

struct StoreFlowableImpl<KEY: Hashable, DATA>: StoreFlowable {

    typealias KEY = KEY
    typealias DATA = DATA

    private let storeFlowableResponder: AnyStoreFlowableResponder<KEY, DATA>
    private var dataSelector: DataSelector<KEY, DATA>

    init(storeFlowableResponder: AnyStoreFlowableResponder<KEY, DATA>) {
        self.storeFlowableResponder = storeFlowableResponder
        dataSelector = DataSelector(
            key: storeFlowableResponder.key,
            dataStateManager: AnyDataStateManager(storeFlowableResponder.flowableDataStateManager),
            cacheDataManager: AnyCacheDataManager(storeFlowableResponder),
            originDataManager: AnyOriginDataManager(storeFlowableResponder),
            needRefresh: { data in storeFlowableResponder.needRefresh(data: data) }
        )
    }

    func asFlow(forceRefresh: Bool) -> AnyPublisher<FlowableState<DATA>, Never> {
        dataSelector.doStateAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false)
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

    func get(type: AsDataType) -> AnyPublisher<DATA, Error> {
        async { yield in
            switch type {
            case .mix:
                try await(dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true))
            case .fromOrigin:
                try await(dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true))
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
        dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true)
    }

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError, awaitFetching: true)
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData)
    }
}
