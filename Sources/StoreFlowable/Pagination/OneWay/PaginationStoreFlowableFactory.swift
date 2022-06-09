//
//  PaginationStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation

/**
 * Abstract factory class for `PaginationStoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol PaginationStoreFlowableFactory: BaseStoreFlowableFactory {
    
    /**
     * The next data saving process to cache.
     * You need to merge cached data & new fetched next data.
     *
     * - parameter cachedData: Currently cached data.
     * - parameter newData: Data to be saved.
     */
    func saveNextDataToCache(cachedData: DATA, newData: DATA, param: PARAM) async

    /**
     * The latest data acquisition process from origin.
     *
     * - returns `Fetched` class including the acquired data.
     */
    func fetchDataFromOrigin(param: PARAM) async throws -> Fetched<DATA>

    /**
     * Next data acquisition process from origin.
     *
     * - parameter nextKey: Key for next data request.
     * - returns `Fetched` class including the acquired data.
     */
    func fetchNextDataFromOrigin(nextKey: String, param: PARAM) async throws -> Fetched<DATA>
}
