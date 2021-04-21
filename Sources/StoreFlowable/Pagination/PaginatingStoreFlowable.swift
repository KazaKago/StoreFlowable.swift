//
//  PaginatingStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PaginatingStoreFlowable: StoreFlowable {

    func requestAdditionalData(continueWhenError: Bool) -> AnyPublisher<Void, Never>
}

public extension PaginatingStoreFlowable {

    func requestAdditionalData(continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        requestAdditionalData(continueWhenError: continueWhenError)
    }
}
