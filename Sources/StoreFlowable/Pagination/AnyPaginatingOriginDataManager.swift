//
//  AnyPaginatingOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

struct AnyPaginatingOriginDataManager<DATA>: PaginatingOriginDataManager {

    typealias DATA = DATA

    private let _fetchDataFromOrigin: () -> AnyPublisher<FetchingResult<DATA>, Error>
    private let _fetchAdditionalDataFromOrigin: (_ cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error>

    init<INNER: PaginatingOriginDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _fetchDataFromOrigin = {
            inner.fetchDataFromOrigin()
        }
        _fetchAdditionalDataFromOrigin = { cachedData in
            inner.fetchAdditionalDataFromOrigin(cachedData: cachedData)
        }
    }

    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<DATA>, Error> {
        _fetchDataFromOrigin()
    }

    func fetchAdditionalDataFromOrigin(cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error> {
        _fetchAdditionalDataFromOrigin(cachedData)
    }
}
