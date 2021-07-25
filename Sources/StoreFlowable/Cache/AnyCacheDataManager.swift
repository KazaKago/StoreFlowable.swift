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

    private let _load: () -> AnyPublisher<DATA?, Never>
    private let _save: (_ newData: DATA?) -> AnyPublisher<Void, Never>
    private let _saveNext: (_ cachedData: DATA, _ newData: DATA) -> AnyPublisher<Void, Never>
    private let _savePrev: (_ cachedData: DATA, _ newData: DATA) -> AnyPublisher<Void, Never>

    init<INNER: CacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _load = {
            inner.load()
        }
        _save = { newData in
            inner.save(newData: newData)
        }
        _saveNext = { cachedData, newData in
            inner.saveNext(cachedData: cachedData, newData: newData)
        }
        _savePrev = { cachedData, newData in
            inner.savePrev(cachedData: cachedData, newData: newData)
        }
    }
    
    init(load: @escaping () -> AnyPublisher<DATA?, Never>, save: @escaping (_ newData: DATA?) -> AnyPublisher<Void, Never>, saveNext: @escaping (_ cachedData: DATA, _ newData: DATA) -> AnyPublisher<Void, Never>, savePrev: @escaping (_ cachedData: DATA, _ newData: DATA) -> AnyPublisher<Void, Never>) {
        _load = load
        _save = save
        _saveNext = saveNext
        _savePrev = savePrev
    }

    func load() -> AnyPublisher<DATA?, Never> {
        _load()
    }

    func save(newData: DATA?) -> AnyPublisher<Void, Never> {
        _save(newData)
    }

    func saveNext(cachedData: DATA, newData: DATA) -> AnyPublisher<Void, Never> {
        _saveNext(cachedData, newData)
    }

    func savePrev(cachedData: DATA, newData: DATA) -> AnyPublisher<Void, Never> {
        _savePrev(cachedData, newData)
    }
}
