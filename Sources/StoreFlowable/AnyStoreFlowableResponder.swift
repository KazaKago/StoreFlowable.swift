//
//  AnyStoreFlowableResponder.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

struct AnyStoreFlowableResponder<KEY: Hashable, DATA>: StoreFlowableResponder {

    typealias KEY = KEY
    typealias DATA = DATA

    private let _key: KEY
    private let _flowableDataStateManager: FlowableDataStateManager<KEY>
    private let _loadData: () -> AnyPublisher<DATA?, Error>
    private let _saveData: (_ data: DATA?) -> AnyPublisher<Void, Error>
    private let _needRefresh: (_ data: DATA) -> AnyPublisher<Bool, Error>
    private let _fetchOrigin: () -> AnyPublisher<DATA, Error>

    init<INNER: StoreFlowableResponder>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _key = inner.key
        _flowableDataStateManager = inner.flowableDataStateManager
        _loadData = {
            inner.loadData()
        }
        _saveData = { data in
            inner.saveData(data: data)
        }
        _needRefresh = { data in
            inner.needRefresh(data: data)
        }
        _fetchOrigin = {
            inner.fetchOrigin()
        }
    }

    var key: KEY {
        _key
    }

    var flowableDataStateManager: FlowableDataStateManager<KEY> {
        _flowableDataStateManager
    }

    func loadData() -> AnyPublisher<DATA?, Error> {
        _loadData()
    }

    func saveData(data: DATA?) -> AnyPublisher<Void, Error> {
        _saveData(data)
    }

    func needRefresh(data: DATA) -> AnyPublisher<Bool, Error> {
        _needRefresh(data)
    }

    func fetchOrigin() -> AnyPublisher<DATA, Error> {
        _fetchOrigin()
    }
}
