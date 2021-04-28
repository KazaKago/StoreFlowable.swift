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

    private let _fetchDataFromOrigin: () -> AnyPublisher<FetchingResult<DATA>, Error>

    init<INNER: OriginDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _fetchDataFromOrigin = {
            inner.fetchDataFromOrigin()
        }
    }

    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<DATA>, Error> {
        _fetchDataFromOrigin()
    }
}
