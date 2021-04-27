//
//  PaginatingDataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine
import CombineAsync

struct PaginatingDataSelector<KEY, DATA> {

    private let key: KEY
    private let dataStateManager: AnyDataStateManager<KEY>
    private let cacheDataManager: AnyPaginatingCacheDataManager<DATA>
    private let originDataManager: AnyPaginatingOriginDataManager<DATA>
    private let needRefresh: (_ cachedData: DATA) -> AnyPublisher<Bool, Never>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyPaginatingCacheDataManager<DATA>, originDataManager: AnyPaginatingOriginDataManager<DATA>, needRefresh: @escaping (_ cachedData: DATA) -> AnyPublisher<Bool, Never>) {
        self.key = key
        self.dataStateManager = dataStateManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.needRefresh = needRefresh
    }

    func load() -> AnyPublisher<DATA?, Never> {
        async { yield in
            yield(try `await`(cacheDataManager.loadDataFromCache()))
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        async { yield in
            try `await`(cacheDataManager.saveDataToCache(newData: newData))
            dataStateManager.saveState(key: key, state: .fixed())
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    func doStateAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, continueWhenError: Bool, awaitFetching: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            switch dataStateManager.loadState(key: key) {
            case .fixed(let isReachLast):
                try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest, currentIsReachLast: isReachLast))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if continueWhenError { try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest, currentIsReachLast: false)) }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, additionalRequest: Bool, currentIsReachLast: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            let cachedData = try `await`(cacheDataManager.loadDataFromCache())
            if (cachedData == nil || forceRefresh || (!additionalRequest && (try! `await`(needRefresh(cachedData!)))) || (additionalRequest && !currentIsReachLast)) {
                try `await`(prepareFetch(cachedData: cachedData, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(cachedData: DATA?, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if clearCacheBeforeFetching { try `await`(cacheDataManager.saveDataToCache(newData: nil)) }
            dataStateManager.saveState(key: key, state: .loading)
            if awaitFetching {
                try `await`(fetchNewData(cachedData: cachedData, clearCacheWhenFetchFails: clearCacheWhenFetchFails, additionalRequest: additionalRequest))
            } else {
                _ = fetchNewData(cachedData: cachedData, clearCacheWhenFetchFails: clearCacheWhenFetchFails, additionalRequest: additionalRequest).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData(cachedData: DATA?, clearCacheWhenFetchFails: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            do {
                var fetchingResult: FetchingResult<DATA>
                if additionalRequest {
                    fetchingResult = try `await`(originDataManager.fetchAdditionalDataFromOrigin(cachedData: cachedData))
                } else {
                    fetchingResult = try `await`(originDataManager.fetchDataFromOrigin())
                }
                if additionalRequest {
                    try `await`(cacheDataManager.saveAdditionalDataToCache(cachedData: cachedData, newData: fetchingResult.data))
                } else {
                    try `await`(cacheDataManager.saveDataToCache(newData: fetchingResult.data))
                }
                dataStateManager.saveState(key: key, state: .fixed(noMoreAdditionalData: fetchingResult.noMoreAdditionalData))
            } catch {
                if clearCacheWhenFetchFails { try `await`(cacheDataManager.saveDataToCache(newData: nil)) }
                dataStateManager.saveState(key: key, state: .error(rawError: error))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
