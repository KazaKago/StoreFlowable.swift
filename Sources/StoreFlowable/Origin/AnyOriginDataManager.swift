//
//  AnyOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct AnyOriginDataManager<DATA>: OriginDataManager {

    typealias DATA = DATA

    private let _fetch: () async throws -> InternalFetched<DATA>
    private let _fetchNext: (_ nextKey: String) async throws -> InternalFetched<DATA>
    private let _fetchPrev: (_ prevKey: String) async throws -> InternalFetched<DATA>

    init<INNER: OriginDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _fetch = {
            try await inner.fetch()
        }
        _fetchNext = { nextKey in
            try await inner.fetchNext(nextKey: nextKey)
        }
        _fetchPrev = { prevKey in
            try await inner.fetchPrev(prevKey: prevKey)
        }
    }

    init(fetch: @escaping () async throws -> InternalFetched<DATA>, fetchNext: @escaping (_ nextKey: String) async throws -> InternalFetched<DATA>, fetchPrev: @escaping (_ prevKey: String) async throws -> InternalFetched<DATA>) {
        _fetch = fetch
        _fetchNext = fetchNext
        _fetchPrev = fetchPrev
    }

    func fetch() async throws -> InternalFetched<DATA> {
        try await _fetch()
    }

    func fetchNext(nextKey: String) async throws -> InternalFetched<DATA> {
        try await _fetchNext(nextKey)
    }

    func fetchPrev(prevKey: String) async throws -> InternalFetched<DATA> {
        try await _fetchPrev(prevKey)
    }
}
