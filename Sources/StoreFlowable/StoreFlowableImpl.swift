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

    private let storeFlowableFactory: AnyStoreFlowableFactory<KEY, DATA>
    private var dataSelector: DataSelector<KEY, DATA>

    init(storeFlowableFactory: AnyStoreFlowableFactory<KEY, DATA>) {
        self.storeFlowableFactory = storeFlowableFactory
        dataSelector = DataSelector(
            key: storeFlowableFactory.key,
            dataStateManager: AnyDataStateManager(storeFlowableFactory.flowableDataStateManager),
            cacheDataManager: AnyCacheDataManager(storeFlowableFactory),
            originDataManager: AnyOriginDataManager(storeFlowableFactory),
            needRefresh: { cachedData in storeFlowableFactory.needRefresh(cachedData: cachedData) }
        )
    }

    func publish(forceRefresh: Bool) -> StatePublisher<DATA> {
        dataSelector.doStateAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false)
            .flatMap { _ in
                storeFlowableFactory.flowableDataStateManager.getFlow(key: storeFlowableFactory.key)
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
        async { _ in
            switch from {
            case .both, .mix:
                try `await`(dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true))
            case .origin, .fromOrigin:
                try `await`(dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true))
            case .cache, .fromCache:
                // do nothing.
                break
            }
        }
        .flatMap {
            storeFlowableFactory.flowableDataStateManager.getFlow(key: storeFlowableFactory.key)
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
                    if data != nil && !(try! `await`(storeFlowableFactory.needRefresh(cachedData: data!))) {
                        yield(data!)
                    } else {
                        throw NoSuchElementError()
                    }
                case .loading:
                    // do nothing.
                    break
                case .error(let rawError):
                    if data != nil && !(try! `await`(storeFlowableFactory.needRefresh(cachedData: data!))) {
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
