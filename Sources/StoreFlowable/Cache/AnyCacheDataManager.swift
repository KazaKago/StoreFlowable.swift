//
//  AnyCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct AnyCacheDataManager<DATA>: CacheDataManager {

    typealias DATA = DATA

    private let _load: () async -> DATA?
    private let _save: (_ newData: DATA?) async -> ()
    private let _saveNext: (_ cachedData: DATA, _ newData: DATA) async -> ()
    private let _savePrev: (_ cachedData: DATA, _ newData: DATA) async -> ()

    init<INNER: CacheDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _load = {
            await inner.load()
        }
        _save = { newData in
            await inner.save(newData: newData)
        }
        _saveNext = { cachedData, newData in
            await inner.saveNext(cachedData: cachedData, newData: newData)
        }
        _savePrev = { cachedData, newData in
            await inner.savePrev(cachedData: cachedData, newData: newData)
        }
    }
    
    init(load: @escaping () async -> DATA?, save: @escaping (_ newData: DATA?) async -> (), saveNext: @escaping (_ cachedData: DATA, _ newData: DATA) async -> (), savePrev: @escaping (_ cachedData: DATA, _ newData: DATA) async -> ()) {
        _load = load
        _save = save
        _saveNext = saveNext
        _savePrev = savePrev
    }

    func load() async -> DATA? {
        await _load()
    }

    func save(newData: DATA?) async {
        await _save(newData)
    }

    func saveNext(cachedData: DATA, newData: DATA) async {
        await _saveNext(cachedData, newData)
    }

    func savePrev(cachedData: DATA, newData: DATA) async {
        await _savePrev(cachedData, newData)
    }
}
