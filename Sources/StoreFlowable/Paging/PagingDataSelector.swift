//
//  PagingDataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine
import CombineAsync

struct PagingDataSelector<KEY, DATA> {

    private let key: KEY
    private let dataStateManager: AnyDataStateManager<KEY>
    private let cacheDataManager: AnyPagingCacheDataManager<DATA>
    private let originDataManager: AnyPagingOriginDataManager<DATA>
    private let needRefresh: (_ data: [DATA]) -> AnyPublisher<Bool, Never>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyPagingCacheDataManager<DATA>, originDataManager: AnyPagingOriginDataManager<DATA>, needRefresh: @escaping (_ data: [DATA]) -> AnyPublisher<Bool, Never>) {
        self.key = key
        self.dataStateManager = dataStateManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.needRefresh = needRefresh
    }

    func load() -> AnyPublisher<[DATA]?, Never> {
        async { yield in
            yield(try await(cacheDataManager.loadData()))
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func update(newData: [DATA]?) -> AnyPublisher<Void, Never> {
        async { yield in
            try await(cacheDataManager.saveData(data: newData, additionalRequest: false))
            dataStateManager.saveState(key: key, state: .fixed())
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    func doStateAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, continueWhenError: Bool, awaitFetching: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            let data = try await(cacheDataManager.loadData())
            switch dataStateManager.loadState(key: key) {
            case .fixed(let isReachLast):
                try await(doDataAction(data: data, forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest, currentIsReachLast: isReachLast))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if continueWhenError { try await(doDataAction(data: data, forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest, currentIsReachLast: false)) }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(data: [DATA]?, forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, additionalRequest: Bool, currentIsReachLast: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if (data == nil || forceRefresh || (try! await(self.needRefresh(data!))) || (additionalRequest && !currentIsReachLast)) {
                try await(prepareFetch(data: data, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, additionalRequest: additionalRequest))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(data: [DATA]?, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if clearCacheBeforeFetching { try await(cacheDataManager.saveData(data: nil, additionalRequest: additionalRequest)) }
            dataStateManager.saveState(key: key, state: .loading)
            if awaitFetching {
                try await(fetchNewData(data: data, clearCacheWhenFetchFails: clearCacheWhenFetchFails, additionalRequest: additionalRequest))
            } else {
                _ = fetchNewData(data: data, clearCacheWhenFetchFails: clearCacheWhenFetchFails, additionalRequest: additionalRequest).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData(data: [DATA]?, clearCacheWhenFetchFails: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            do {
                let fetchedData = try await(originDataManager.fetchOrigin(data: data, additionalRequest: additionalRequest))
                let mergedData = additionalRequest ? (data ?? []) + fetchedData : fetchedData
                try await(cacheDataManager.saveData(data: mergedData, additionalRequest: additionalRequest))
                let isReachLast = fetchedData.isEmpty
                dataStateManager.saveState(key: key, state: .fixed(isReachLast: isReachLast))
            } catch {
                if clearCacheWhenFetchFails { try await(cacheDataManager.saveData(data: nil, additionalRequest: additionalRequest)) }
                dataStateManager.saveState(key: key, state: .error(rawError: error))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
