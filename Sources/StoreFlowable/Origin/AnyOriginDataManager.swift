//
//  AnyOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

struct AnyOriginDataManager<DATA>: OriginDataManager {

    typealias DATA = DATA

    private let _fetch: () -> AnyPublisher<InternalFetched<DATA>, Error>
    private let _fetchNext: (_ nextKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>
    private let _fetchPrev: (_ prevKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>

    init<INNER: OriginDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _fetch = {
            inner.fetch()
        }
        _fetchNext = { nextKey in
            inner.fetchNext(nextKey: nextKey)
        }
        _fetchPrev = { prevKey in
            inner.fetchPrev(prevKey: prevKey)
        }
    }

    init(fetch: @escaping () -> AnyPublisher<InternalFetched<DATA>, Error>, fetchNext: @escaping (_ nextKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>, fetchPrev: @escaping (_ prevKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>) {
        _fetch = fetch
        _fetchNext = fetchNext
        _fetchPrev = fetchPrev
    }

    func fetch() -> AnyPublisher<InternalFetched<DATA>, Error> {
        _fetch()
    }

    func fetchNext(nextKey: String) -> AnyPublisher<InternalFetched<DATA>, Error> {
        _fetchNext(nextKey)
    }

    func fetchPrev(prevKey: String) -> AnyPublisher<InternalFetched<DATA>, Error> {
        _fetchPrev(prevKey)
    }
}
