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
    private let needRefresh: (_ data: DATA) -> AnyPublisher<Bool, Never>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, needRefresh: @escaping (DATA) -> AnyPublisher<Bool, Never>) {
        self.key = key
        self.dataStateManager = dataStateManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.needRefresh = needRefresh
    }

    func load() -> AnyPublisher<DATA?, Never> {
        async { yield in
            yield(try await(cacheDataManager.loadData()))
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        async { yield in
            try await(cacheDataManager.saveData(data: newData))
            dataStateManager.saveState(key: key, state: .fixed())
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    func doStateAction(forceRefresh: Bool, clearCache: Bool, fetchAtError: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            switch dataStateManager.loadState(key: key) {
            case .fixed(_):
                try await(doDataAction(forceRefresh: forceRefresh, clearCache: clearCache, fetchAsync: fetchAsync))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if fetchAtError {
                    try await(prepareFetch(clearCache: clearCache, fetchAsync: fetchAsync))
                }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(forceRefresh: Bool, clearCache: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            let data = try await(cacheDataManager.loadData())
            if (data == nil || forceRefresh || (try! await(self.needRefresh(data!)))) {
                try await(prepareFetch(clearCache: clearCache, fetchAsync: fetchAsync))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(clearCache: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Never> {
        async { yield in
            if clearCache {
                try await(cacheDataManager.saveData(data: nil))
            }
            dataStateManager.saveState(key: key, state: .loading)
            if fetchAsync {
                _ = fetchNewData().sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            } else {
                try await(fetchNewData())
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData() -> AnyPublisher<Void, Never> {
        async { yield in
            do {
                let fetchedData = try await(originDataManager.fetchOrigin())
                try await(cacheDataManager.saveData(data: fetchedData))
                dataStateManager.saveState(key: key, state: .fixed())
            } catch {
                dataStateManager.saveState(key: key, state: .error(rawError: error))
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}