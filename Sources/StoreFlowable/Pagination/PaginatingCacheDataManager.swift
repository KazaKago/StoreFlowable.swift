//
//  PaginatingCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

/**
 * Provides functions related to data input / output from cache.
 */
public protocol PaginatingCacheDataManager: CacheDataManager {

    /**
     * Saves additional data from pagination.
     *
     * Must be combined with existing cached data before saving when implementing this method.
     *
     * - parameter cachedData: existing cache data.
     * - parameter newData: Newly added data.
     */
    func saveAdditionalDataToCache(cachedData: DATA?, newData: DATA) -> AnyPublisher<Void, Never>
}
