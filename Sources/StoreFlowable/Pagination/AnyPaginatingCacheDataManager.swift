//
//  AnyPaginatingCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

struct AnyPaginatingCacheDataManager<DATA>: PaginatingCacheDataManager {

    typealias DATA = DATA

    private let _loadDataFromCache: () -> AnyPublisher<DATA?, Never>
    private let _saveDataToCache: (_ newData: DATA?) -> AnyPublisher<Void, Never>
    private let _saveAdditionalDataToCache: (_ cachedData: DATA?, _ newData: DATA) -> AnyPublisher<Void, Never>

    init<INNER: PaginatingCacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _loadDataFromCache = {
            inner.loadDataFromCache()
        }
        _saveDataToCache = { newData in
            inner.saveDataToCache(newData: newData)
        }
        _saveAdditionalDataToCache = { (cachedData, newData) in
            inner.saveAdditionalDataToCache(cachedData: cachedData, newData: newData)
        }
    }

    func loadDataFromCache() -> AnyPublisher<DATA?, Never> {
        _loadDataFromCache()
    }

    func saveDataToCache(newData: DATA?) -> AnyPublisher<Void, Never> {
        _saveDataToCache(newData)
    }

    func saveAdditionalDataToCache(cachedData: DATA?, newData: DATA) -> AnyPublisher<Void, Never> {
        _saveAdditionalDataToCache(cachedData, newData)
    }
}
