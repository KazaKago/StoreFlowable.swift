//
//  PaginatingStoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine
import CombineAsync

struct PaginatingStoreFlowableImpl<KEY: Hashable, DATA>: PaginatingStoreFlowable {

    typealias KEY = KEY
    typealias DATA = DATA

    private let key: KEY
    private let flowableDataStateManager: FlowableDataStateManager<KEY>
    private let needRefresh: (_ cachedData: DATA) -> AnyPublisher<Bool, Never>
    private let dataSelector: PaginatingDataSelector<KEY, DATA>

    init(key: KEY, flowableDataStateManager: FlowableDataStateManager<KEY>, cacheDataManager: AnyPaginatingCacheDataManager<DATA>, originDataManager: AnyPaginatingOriginDataManager<DATA>, needRefresh: @escaping (_ cachedData: DATA) -> AnyPublisher<Bool, Never>) {
        self.key = key
        self.flowableDataStateManager = flowableDataStateManager
        self.needRefresh = needRefresh
        self.dataSelector = PaginatingDataSelector(
            key: key,
            dataStateManager: AnyDataStateManager(flowableDataStateManager),
            cacheDataManager: cacheDataManager,
            originDataManager: originDataManager,
            needRefresh: needRefresh
        )
    }

    func publish(forceRefresh: Bool) -> StatePublisher<DATA> {
        dataSelector.doStateAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false, additionalRequest: false)
            .flatMap { _ in
                flowableDataStateManager.getFlow(key: key)
            }
            .flatMap { dataState in
                dataSelector.load().map { data in
                    (dataState, data)
                }
            }
            .map { (dataState, data) in
                let content = StateContent.wrap(rawContent: data)
                return dataState.mapState(content: content)
            }
            .eraseToAnyPublisher()
    }

    func getData(from: GettingFrom) -> AnyPublisher<DATA?, Never> {
        requireData(from: from)
            .tryMap { data -> DATA? in
                data
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func requireData(from: GettingFrom) -> AnyPublisher<DATA, Error> {
        async { yield in
            switch from {
            case .both, .mix:
                try `await`(dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, additionalRequest: false))
            case .origin, .fromOrigin:
                try `await`(dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, additionalRequest: false))
            case .cache, .fromCache:
                //do nothing.
                break
            }
        }
        .flatMap {
            flowableDataStateManager.getFlow(key: key)
                .setFailureType(to: Error.self) // Workaround for macOS10.15/iOS13.0/tvOS13.0/watchOS6.0 https://www.donnywals.com/configuring-error-types-when-using-flatmap-in-combine/
        }
        .flatMap { dataState in
            dataSelector.load().map { data in
                (dataState, data)
            }
            .setFailureType(to: Error.self) // Workaround for macOS10.15/iOS13.0/tvOS13.0/watchOS6.0 https://www.donnywals.com/configuring-error-types-when-using-flatmap-in-combine/
        }
        .flatMap { (dataState, data) in
            async { yield in
                switch dataState {
                case .fixed:
                    if (data != nil && !(try! `await`(needRefresh(data!)))) {
                        yield(data!)
                    } else {
                        throw NoSuchElementError()
                    }
                case .loading:
                    // do nothing.
                    break
                case .error(let rawError):
                    if (data != nil && !(try! `await`(needRefresh(data!)))) {
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
        dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, additionalRequest: false)
    }

    func refresh(clearCacheWhenFetchFails: Bool, continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: clearCacheWhenFetchFails, continueWhenError: continueWhenError, awaitFetching: true, additionalRequest: false)
    }

    func requestAdditionalData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: false, continueWhenError: continueWhenError, awaitFetching: true, additionalRequest: true)
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData)
    }
}
