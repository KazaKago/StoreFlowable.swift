//
//  BaseStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation
import Combine

/**
 * Common function of `StoreFlowableFactory`, `PaginationStoreFlowableFactory`, `TwoWayPaginationStoreFlowableFactory` protocols.
 */
public protocol BaseStoreFlowableFactory {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    associatedtype PARAM: Hashable
    /**
     * Specify the type of data to be handled.
     */
    associatedtype DATA

    /**
     * Used for data state management.
     *
     * Create a class that inherits `FlowableDataStateManager` and assign it.
     */
    var flowableDataStateManager: FlowableDataStateManager<PARAM> { get }

    /**
     * The data loading process from cache.
     *
     * - returns: The loaded data.
     */
    func loadDataFromCache(param: PARAM) -> AnyPublisher<DATA?, Never>

    /**
     * The data saving process to cache.
     *
     * - parameter newData: Data to be saved.
     */
    func saveDataToCache(newData: DATA?, param: PARAM) -> AnyPublisher<Void, Never>

    /**
     * Determine if the cache is valid.
     *
     * - parameter cachedData: Current cache data.
     * - returns: Returns `true` if the cache is invalid and refresh is needed.
     */
    func needRefresh(cachedData: DATA, param: PARAM) -> AnyPublisher<Bool, Never>
}
