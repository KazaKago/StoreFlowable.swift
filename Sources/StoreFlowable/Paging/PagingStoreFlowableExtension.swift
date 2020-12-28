//
//  PagingStoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public extension PagingStoreFlowableResponder {

    func create() -> AnyPagingStoreFlowable<KEY, DATA> {
        AnyPagingStoreFlowable(PagingStoreFlowableImpl(storeFlowableResponder: AnyPagingStoreFlowableResponder(self)))
    }
}

public extension PagingStoreFlowable {

    func getOrNil(type: AsDataType = .mix) -> AnyPublisher<[DATA]?, Never> {
        get(type: type)
            .tryMap { data in
                data
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
