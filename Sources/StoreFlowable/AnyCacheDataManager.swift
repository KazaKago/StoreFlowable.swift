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

    private let _loadData: () -> AnyPublisher<DATA?, Error>
    private let _saveData: (_ data: DATA?) -> AnyPublisher<Void, Error>

    init<INNER: CacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _loadData = {
            inner.loadData()
        }
        _saveData = { data in
            inner.saveData(data: data)
        }
    }

    func loadData() -> AnyPublisher<DATA?, Error> {
        _loadData()
    }

    func saveData(data: DATA?) -> AnyPublisher<Void, Error> {
        _saveData(data)
    }
}
