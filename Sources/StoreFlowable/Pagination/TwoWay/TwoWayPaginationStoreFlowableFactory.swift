//
//  TwoWayPaginationStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation
import Combine

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
    func saveNextDataToCache(cachedData: DATA, newData: DATA, param: PARAM) -> AnyPublisher<Void, Never>

    /**
     * The previous data saving process to cache.
     * You need to merge cached data & new fetched previous data.
     *
     * - parameter cachedData: Currently cached data.
     * - parameter newData: Data to be saved.
     */
    func savePrevDataToCache(cachedData: DATA, newData: DATA, param: PARAM) -> AnyPublisher<Void, Never>

    /**
     * The latest data acquisition process from origin.
     *
     * - returns `Fetched` class including the acquired data.
     */
    func fetchDataFromOrigin(param: PARAM) -> AnyPublisher<FetchedInitial<DATA>, Error>

    /**
     * Next data acquisition process from origin.
     *
     * - parameter nextKey: Key for next data request.
     * - returns `Fetched` class including the acquired data.
     */
    func fetchNextDataFromOrigin(nextKey: String, param: PARAM) -> AnyPublisher<FetchedNext<DATA>, Error>

    /**
     * Previous data acquisition process from origin.
     *
     * - parameter prevKey: Key for previous data request.
     * - returns `Fetched` class including the acquired data.
     */
    func fetchPrevDataFromOrigin(prevKey: String, param: PARAM) -> AnyPublisher<FetchedPrev<DATA>, Error>
}
