//
//  DataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine
import CombineAsync

class DataSelector<KEY, DATA> {

    private let key: KEY
    private let dataStateManager: AnyDataStateManager<KEY>
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let originDataManager: AnyOriginDataManager<DATA>
    private let needRefresh: (_ data: DATA) -> AnyPublisher<Bool, Error>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, needRefresh: @escaping (DATA) -> AnyPublisher<Bool, Error>) {
        self.key = key
        self.dataStateManager = dataStateManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.needRefresh = needRefresh
    }

    func load() -> AnyPublisher<DATA?, Error> {
        async {
            try await(self.cacheDataManager.loadData())
        }.eraseToAnyPublisher()
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Error> {
        async {
            try await(self.cacheDataManager.saveData(data: newData))
            self.dataStateManager.saveState(key: self.key, state: .fixed())
        }.eraseToAnyPublisher()
    }

    func doStateAction(forceRefresh: Bool, clearCache: Bool, fetchAtError: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Error> {
        async {
            switch self.dataStateManager.loadState(key: self.key) {
            case .fixed(_):
                try await(self.doDataAction(forceRefresh: forceRefresh, clearCache: clearCache, fetchAsync: fetchAsync))
            case .loading:
                // do nothing.
                break
            case .error(_):
                if fetchAtError {
                    try await(self.prepareFetch(clearCache: clearCache, fetchAsync: fetchAsync))
                }
            }
        }.eraseToAnyPublisher()
    }

    private func doDataAction(forceRefresh: Bool, clearCache: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Error> {
        async {
            let data = try await(self.cacheDataManager.loadData())
            if (data == nil || forceRefresh || (try! await(self.needRefresh(data!)))) {
                try await(self.prepareFetch(clearCache: clearCache, fetchAsync: fetchAsync))
            }
        }.eraseToAnyPublisher()
    }

    private func prepareFetch(clearCache: Bool, fetchAsync: Bool) -> AnyPublisher<Void, Error> {
        async {
            if clearCache {
                try await(self.cacheDataManager.saveData(data: nil))
            }
            self.dataStateManager.saveState(key: self.key, state: .loading)
            if fetchAsync {
                _ = self.fetchNewData().sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            } else {
                try await(self.fetchNewData())
            }
        }.eraseToAnyPublisher()
    }

    private func fetchNewData() -> AnyPublisher<Void, Error> {
        async {
            do {
                let fetchedData = try await(self.originDataManager.fetchOrigin())
                try await(self.cacheDataManager.saveData(data: fetchedData))
                self.dataStateManager.saveState(key: self.key, state: .fixed())
            } catch {
                self.dataStateManager.saveState(key: self.key, state: .error(error: error))
            }
        }.eraseToAnyPublisher()
    }
}
