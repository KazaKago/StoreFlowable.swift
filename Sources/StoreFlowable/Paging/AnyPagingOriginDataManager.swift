//
//  AnyPagingOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

struct AnyPagingOriginDataManager<DATA>: PagingOriginDataManager {

    typealias DATA = DATA

    private let _fetchOrigin: (_ data: [DATA]?, _ additionalRequest: Bool) -> AnyPublisher<[DATA], Error>

    init<INNER: PagingOriginDataManager>(_ inner: INNER) where INNER.DATA == DATA {
        _fetchOrigin = { (data, additionalRequest) in
            inner.fetchOrigin(data: data, additionalRequest: additionalRequest)
        }
    }

    func fetchOrigin(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<[DATA], Error> {
        _fetchOrigin(data, additionalRequest)
    }
}
