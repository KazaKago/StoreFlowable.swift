//
//  AnyPaginatingStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

struct AnyPaginatingStoreFlowableFactory<KEY: Hashable, DATA>: PaginatingStoreFlowableFactory {

    typealias KEY = KEY
    typealias DATA = DATA

    private let _key: () -> KEY
    private let _flowableDataStateManager: () -> FlowableDataStateManager<KEY>
    private let _loadDataFromCache: () -> AnyPublisher<DATA?, Never>
    private let _saveDataToCache: (_ newData: DATA?) -> AnyPublisher<Void, Never>
    private let _saveAdditionalDataToCache: (_ cachedData: DATA?, _ newData: DATA) -> AnyPublisher<Void, Never>
    private let _fetchDataFromOrigin: () -> AnyPublisher<FetchingResult<DATA>, Error>
    private let _fetchAdditionalDataFromOrigin: (_ cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error>
    private let _needRefresh: (_ cachedData: DATA) -> AnyPublisher<Bool, Never>

    init<INNER: PaginatingStoreFlowableFactory>(_ inner: INNER) where INNER.KEY == KEY, INNER.DATA == DATA {
        _key = {
            inner.key
        }
        _flowableDataStateManager = {
            inner.flowableDataStateManager
        }
        _loadDataFromCache = {
            inner.loadDataFromCache()
        }
        _saveDataToCache = { newData in
            inner.saveDataToCache(newData: newData)
        }
        _saveAdditionalDataToCache = { (cachedData, newData) in
            inner.saveAdditionalDataToCache(cachedData: cachedData, newData: newData)
        }
        _fetchDataFromOrigin = {
            inner.fetchDataFromOrigin()
        }
        _fetchAdditionalDataFromOrigin = { cachedData in
            inner.fetchAdditionalDataFromOrigin(cachedData: cachedData)
        }
        _needRefresh = { cachedData in
            inner.needRefresh(cachedData: cachedData)
        }
    }

    var key: KEY {
        _key()
    }

    var flowableDataStateManager: FlowableDataStateManager<KEY> {
        _flowableDataStateManager()
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

    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<DATA>, Error> {
        _fetchDataFromOrigin()
    }

    func fetchAdditionalDataFromOrigin(cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error> {
        _fetchAdditionalDataFromOrigin(cachedData)
    }

    func needRefresh(cachedData: DATA) -> AnyPublisher<Bool, Never> {
        _needRefresh(cachedData)
    }
}
