//
//  AnyRequestKeyManager.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/08.
//

import Foundation

struct AnyRequestKeyManager: RequestKeyManager {

    private let _loadNext: () async -> String?
    private let _saveNext: (_ requestKey: String?) async -> ()
    private let _loadPrev: () async -> String?
    private let _savePrev: (_ requestKey: String?) async -> ()

    init<INNER: RequestKeyManager>(_ inner: INNER) {
        _loadNext = {
            await inner.loadNext()
        }
        _saveNext = { requestKey in
            await inner.saveNext(requestKey: requestKey)
        }
        _loadPrev = {
            await inner.loadPrev()
        }
        _savePrev = { requestKey in
            await inner.savePrev(requestKey: requestKey)
        }
    }
    
    init(loadNext: @escaping () async -> String?, saveNext: @escaping (_ requestKey: String?) async -> (), loadPrev: @escaping () async -> String?, savePrev: @escaping (_ requestKey: String?) async -> ()) {
        _loadNext = loadNext
        _saveNext = saveNext
        _loadPrev = loadPrev
        _savePrev = savePrev
    }

    func loadNext() async -> String? {
        await _loadNext()
    }

    func saveNext(requestKey: String?) async {
        await _saveNext(requestKey)
    }

    func loadPrev() async -> String? {
        await _loadPrev()
    }

    func savePrev(requestKey: String?) async {
        await _savePrev(requestKey)
    }
}
