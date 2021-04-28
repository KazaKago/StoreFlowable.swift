//
//  AnyCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

struct AnyCacheDataManager<DATA>: CacheDataManager {

    typealias DATA = DATA

    private let _loadDataFromCache: () -> AnyPublisher<DATA?, Never>
    private let _saveDataToCache: (_ data: DATA?) -> AnyPublisher<Void, Never>

    init<INNER: CacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _loadDataFromCache = {
            inner.loadDataFromCache()
        }
        _saveDataToCache = { newData in
            inner.saveDataToCache(newData: newData)
        }
    }

    func loadDataFromCache() -> AnyPublisher<DATA?, Never> {
        _loadDataFromCache()
    }

    func saveDataToCache(newData: DATA?) -> AnyPublisher<Void, Never> {
        _saveDataToCache(newData)
    }
}
