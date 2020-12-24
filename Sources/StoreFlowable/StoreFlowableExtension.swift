//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

public extension StoreFlowableResponder {

    func create() -> AnyStoreFlowable<KEY, DATA> {
        AnyStoreFlowable(StoreFlowableImpl(storeFlowableResponder: AnyStoreFlowableResponder(self)))
    }
}

public extension StoreFlowable {

    func getOrNil(type: AsDataType = .mix) -> AnyPublisher<DATA?, Never> {
        get(type: type)
            .tryMap { data -> DATA? in
                data
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
