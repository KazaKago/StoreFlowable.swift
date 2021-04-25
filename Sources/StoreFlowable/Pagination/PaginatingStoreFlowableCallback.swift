//
//  PaginatingStoreFlowableCallback.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

/**
 * Callback class used from `PaginatingStoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol PaginatingStoreFlowableCallback: PaginatingCacheDataManager, PaginatingOriginDataManager {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    associatedtype KEY: Hashable
    /**
     * Specify the type of data to be handled.
     */
    associatedtype DATA

    /**
     * Key to which data to get.
     *
     * Please implement so that you can pass the key from the outside.
     */
    var key: KEY { get }

    /**
     * Used for data state management.
     *
     * Create a class that inherits `FlowableDataStateManager` and assign it.
     */
    var flowableDataStateManager: FlowableDataStateManager<KEY> { get }

    /**
     * Determine if the cache is valid.
     *
     * - parameter cachedData: Current cache data.
     * - returns: Returns `true` if the cache is invalid and refresh is needed.
     */
    func needRefresh(cachedData: DATA) -> AnyPublisher<Bool, Never>
}
