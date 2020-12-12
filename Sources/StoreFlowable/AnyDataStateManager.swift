//
//  AnyDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct AnyDataStateManager<KEY>: DataStateManager {

    typealias KEY = KEY

    private let _loadState: (_ key: KEY) -> DataState
    private let _saveState: (_ key: KEY, DataState) -> Void

    init<INNER: DataStateManager>(_ inner: INNER) where INNER.KEY == KEY {
        _loadState = { key in
            inner.loadState(key: key)
        }
        _saveState = { key, state in
            inner.saveState(key: key, state: state)
        }
    }

    func loadState(key: KEY) -> DataState {
        _loadState(key)
    }

    func saveState(key: KEY, state: DataState) {
        return _saveState(key, state)
    }
}
