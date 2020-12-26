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

    func doStateAction(forceRefresh: Bool, clearCache: Bool, fetchAtError: Bool, fetchAsync: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            let data = try await(cacheDataManager.loadData())
            switch dataStateManager.loadState(key: key) {
            case .fixed(let isReachLast):
                try await(doDataAction(data: data, forceRefresh: forceRefresh, clearCache: clearCache, fetchAsync: fetchAsync, additionalRequest: additionalRequest, currentIsReachLast: isReachLast))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if fetchAtError {
                    try await(prepareFetch(data: data, clearCache: clearCache, fetchAsync: fetchAsync, additionalRequest: additionalRequest))
                }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(data: [DATA]?, forceRefresh: Bool, clearCache: Bool, fetchAsync: Bool, additionalRequest: Bool, currentIsReachLast: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if (data == nil || forceRefresh || (try! await(self.needRefresh(data!))) || (additionalRequest && !currentIsReachLast)) {
                try await(prepareFetch(data: data, clearCache: clearCache, fetchAsync: fetchAsync, additionalRequest: additionalRequest))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(data: [DATA]?, clearCache: Bool, fetchAsync: Bool, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if clearCache {
                try await(cacheDataManager.saveData(data: nil, additionalRequest: additionalRequest))
            }
            dataStateManager.saveState(key: key, state: .loading)
            if fetchAsync {
                _ = fetchNewData(data: data, additionalRequest: additionalRequest).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            } else {
                try await(fetchNewData(data: data, additionalRequest: additionalRequest))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            do {
                let fetchedData = try await(originDataManager.fetchOrigin(data: data, additionalRequest: additionalRequest))
                let mergedData = additionalRequest ? (data ?? []) + fetchedData : fetchedData
                try await(cacheDataManager.saveData(data: mergedData, additionalRequest: additionalRequest))
                let isReachLast = fetchedData.isEmpty
                dataStateManager.saveState(key: key, state: .fixed(isReachLast: isReachLast))
            } catch {
                dataStateManager.saveState(key: key, state: .error(rawError: error))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
