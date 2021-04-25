//
//  PaginatingStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

/**
 * Provides input / output methods that abstract the data acquisition destination.
 *
 * This class is generated from `PaginatingStoreFlowableCallback.create`.
 */
public protocol PaginatingStoreFlowable: StoreFlowable {

    /**
     * Request additional data.
     *
     * Do nothing if there is no additional data or if already data retrieving.
     *
     * - parameter continueWhenError: Even if the data state is an `State.error` when `refresh` is called, the refresh will continue. Default value is `true`.
     */
    func requestAdditionalData(continueWhenError: Bool) -> AnyPublisher<Void, Never>
}

public extension PaginatingStoreFlowable {

    func requestAdditionalData(continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        requestAdditionalData(continueWhenError: continueWhenError)
    }
}
