//
//  AnyDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct AnyDataStateManager<KEY>: DataStateManager {

    typealias KEY = KEY

    private let _load: (_ key: KEY) -> DataState
    private let _save: (_ key: KEY, DataState) -> Void

    init<INNER: DataStateManager>(_ inner: INNER) where INNER.KEY == KEY {
        _load = { key in
            inner.load(key: key)
        }
        _save = { key, state in
            inner.save(key: key, state: state)
        }
    }

    init(load: @escaping (_ key: KEY) -> DataState, save: @escaping (_ key: KEY, DataState) -> Void) {
        _load = load
        _save = save
    }

    func load(key: KEY) -> DataState {
        _load(key)
    }

    func save(key: KEY, state: DataState) {
        return _save(key, state)
    }
}
