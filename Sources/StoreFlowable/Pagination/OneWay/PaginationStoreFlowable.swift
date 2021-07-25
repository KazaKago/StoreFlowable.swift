//
//  PaginationStoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

/**
 * Provides input / output methods that abstract the data acquisition destination.
 *
 * This class is generated from `PaginationStoreFlowableFactory.create`.
 */
public protocol PaginationStoreFlowable: StoreFlowable {

    /**
     * Request next data.
     *
     * Do nothing if there is no additional data or if already data retrieving.
     *
     * - parameter continueWhenError: Even if the data state is an `LoadingState.error` when `refresh` is called, the refresh will continue. Default value is `true`.
     */
    func requestNextData(continueWhenError: Bool) -> AnyPublisher<Void, Never>
    
    /**
     * Treat the passed data as the latest acquired data.
     * and the new data will be notified.
     *
     * Use when new data is created or acquired externally.
     *
     * - parameter newData: Latest data.
     * - parameter nextKey: Key for next request. If null is set, the stored key will be used.
     */
    func update(newData: DATA?, nextKey: String?) -> AnyPublisher<Void, Never>
}

public extension PaginationStoreFlowable {

    func requestNextData(continueWhenError: Bool = true) -> AnyPublisher<Void, Never> {
        requestNextData(continueWhenError: continueWhenError)
    }

    func update(newData: DATA?, nextKey: String? = nil) -> AnyPublisher<Void, Never> {
        update(newData: newData, nextKey: nextKey)
    }
}
