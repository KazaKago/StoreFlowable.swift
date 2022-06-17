//
//  AnyDataStateManager.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/08.
//

struct AnyDataStateManager: DataStateManager {

    private let _load: () -> DataState
    private let _save: (_ state: DataState) -> ()

    init<INNER: DataStateManager>(_ inner: INNER) {
        _load = {
            inner.load()
        }
        _save = { state in
            inner.save(state: state)
        }
    }

    init(load: @escaping () -> DataState, save: @escaping (_ state: DataState) -> ()) {
        _load = load
        _save = save
    }

    func load() -> DataState {
        _load()
    }
    
    func save(state: DataState) {
        _save(state)
    }
}
