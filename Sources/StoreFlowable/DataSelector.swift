//
//  DataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine
import CombineAsync

struct DataSelector<KEY, DATA> {

    private let key: KEY
    private let dataStateManager: AnyDataStateManager<KEY>
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let originDataManager: AnyOriginDataManager<DATA>
    private let needRefresh: (_ cachedData: DATA) -> AnyPublisher<Bool, Never>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, needRefresh: @escaping (_ data: DATA) -> AnyPublisher<Bool, Never>) {
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
        async { _ in
            try `await`(cacheDataManager.saveDataToCache(newData: newData))
            dataStateManager.saveState(key: key, state: .fixed())
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    func doStateAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, continueWhenError: Bool, awaitFetching: Bool) -> AnyPublisher<Void, Never> {
        async { _ in
            switch dataStateManager.loadState(key: key) {
            case .fixed(_):
                try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if continueWhenError { try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching)) }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool) -> AnyPublisher<Void, Never> {
        async { _ in
            let data = try `await`(cacheDataManager.loadDataFromCache())
            if data == nil || forceRefresh || (try! `await`(needRefresh(data!))) {
                try `await`(prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool) -> AnyPublisher<Void, Never> {
        async { _ in
            if clearCacheBeforeFetching { try `await`(cacheDataManager.saveDataToCache(newData: nil)) }
            dataStateManager.saveState(key: key, state: .loading)
            if awaitFetching {
                try `await`(fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails))
            } else {
                _ = fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData(clearCacheWhenFetchFails: Bool) -> AnyPublisher<Void, Never> {
        async { _ in
            do {
                let fetchingResult = try `await`(originDataManager.fetchDataFromOrigin())
                try `await`(cacheDataManager.saveDataToCache(newData: fetchingResult.data))
                dataStateManager.saveState(key: key, state: .fixed())
            } catch {
                if clearCacheWhenFetchFails { try `await`(cacheDataManager.saveDataToCache(newData: nil)) }
                dataStateManager.saveState(key: key, state: .error(rawError: error))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
