//
//  AnyPagingStoreFlowableResponder.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

struct AnyPagingStoreFlowableResponder<KEY: Hashable, DATA>: PagingStoreFlowableResponder {

    typealias KEY = KEY
    typealias DATA = DATA

    private let _key: KEY
    private let _flowableDataStateManager: FlowableDataStateManager<KEY>
    private let _loadData: () -> AnyPublisher<[DATA]?, Never>
    private let _saveData: (_ data: [DATA]?, _ additionalRequest: Bool) -> AnyPublisher<Void, Never>
    private let _fetchOrigin: (_ data: [DATA]?, _ additionalRequest: Bool) -> AnyPublisher<[DATA], Error>
    private let _needRefresh: (_ data: [DATA]) -> AnyPublisher<Bool, Never>

    init<INNER: PagingStoreFlowableResponder>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _key = inner.key
        _flowableDataStateManager = inner.flowableDataStateManager
        _loadData = {
            inner.loadData()
        }
        _saveData = { (data, additionalRequest) in
            inner.saveData(data: data, additionalRequest: additionalRequest)
        }
        _fetchOrigin = { (data, additionalRequest) in
            inner.fetchOrigin(data: data, additionalRequest: additionalRequest)
        }
        _needRefresh = { data in
            inner.needRefresh(data: data)
        }
    }

    var key: KEY {
        _key
    }

    var flowableDataStateManager: FlowableDataStateManager<KEY> {
        _flowableDataStateManager
    }

    func loadData() -> AnyPublisher<[DATA]?, Never> {
        _loadData()
    }

    func saveData(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        _saveData(data, additionalRequest)
    }

    func fetchOrigin(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<[DATA], Error> {
        _fetchOrigin(data, additionalRequest)
    }

    func needRefresh(data: [DATA]) -> AnyPublisher<Bool, Never> {
        _needRefresh(data)
    }
}
