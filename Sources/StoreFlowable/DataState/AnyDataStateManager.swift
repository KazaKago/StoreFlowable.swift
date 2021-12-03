//
//  AnyDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct AnyDataStateManager<PARAM>: DataStateManager {

    typealias PARAM = PARAM

    private let _load: (_ param: PARAM) -> DataState
    private let _save: (_ param: PARAM, DataState) -> Void

    init<INNER: DataStateManager>(_ inner: INNER) where INNER.PARAM == PARAM {
        _load = { param in
            inner.load(param: param)
        }
        _save = { param, state in
            inner.save(param: param, state: state)
        }
    }

    init(load: @escaping (_ param: PARAM) -> DataState, save: @escaping (_ param: PARAM, DataState) -> Void) {
        _load = load
        _save = save
    }

    func load(param: PARAM) -> DataState {
        _load(param)
    }

    func save(param: PARAM, state: DataState) {
        return _save(param, state)
    }
}
