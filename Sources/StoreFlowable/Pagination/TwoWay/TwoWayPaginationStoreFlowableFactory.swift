//
//  TwoWayPaginationStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

/**
 * Abstract factory class for `TwoWayPaginationStoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol TwoWayPaginationStoreFlowableFactory: BaseStoreFlowableFactory {
    
    /**
     * The next data saving process to cache.
     * You need to merge cached data & new fetched next data.
     *
     * - parameter cachedData: Currently cached data.
     * - parameter newData: Data to be saved.
     */
    func saveNextDataToCache(cachedData: DATA, newData: DATA, param: PARAM) async

    /**
     * The previous data saving process to cache.
     * You need to merge cached data & new fetched previous data.
     *
     * - parameter cachedData: Currently cached data.
     * - parameter newData: Data to be saved.
     */
    func savePrevDataToCache(cachedData: DATA, newData: DATA, param: PARAM) async

    /**
     * The latest data acquisition process from origin.
     *
     * - returns `Fetched` class including the acquired data.
     */
    func fetchDataFromOrigin(param: PARAM) async throws -> FetchedInitial<DATA>

    /**
     * Next data acquisition process from origin.
     *
     * - parameter nextKey: Key for next data request.
     * - returns `Fetched` class including the acquired data.
     */
    func fetchNextDataFromOrigin(nextKey: String, param: PARAM) async throws -> FetchedNext<DATA>

    /**
     * Previous data acquisition process from origin.
     *
     * - parameter prevKey: Key for previous data request.
     * - returns `Fetched` class including the acquired data.
     */
    func fetchPrevDataFromOrigin(prevKey: String, param: PARAM) async throws -> FetchedPrev<DATA>
}
