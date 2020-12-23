//
//  AnyPagingCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

struct AnyPagingCacheDataManager<DATA>: PagingCacheDataManager {

    typealias DATA = DATA

    private let _loadData: () -> AnyPublisher<[DATA]?, Never>
    private let _saveData: (_ data: [DATA]?, _ additionalRequest: Bool) -> AnyPublisher<Void, Never>

    init<INNER: PagingCacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _loadData = {
            inner.loadData()
        }
        _saveData = { (data, additionalRequest) in
            inner.saveData(data: data, additionalRequest: additionalRequest)
        }
    }

    func loadData() -> AnyPublisher<[DATA]?, Never> {
        _loadData()
    }

    func saveData(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        _saveData(data, additionalRequest)
    }
}
