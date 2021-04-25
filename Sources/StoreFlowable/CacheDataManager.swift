//
//  CacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

/**
 * Provides functions related to data input / output from cache.
 */
public protocol CacheDataManager {

    /**
     * Specify the type of data to be handled.
     */
    associatedtype DATA

    /**
     * The data loading process from cache.
     *
     * - returns: The loaded data.
     */
    func loadDataFromCache() -> AnyPublisher<DATA?, Never>

    /**
     * The data saving process to cache.
     *
     * - parameter newData: Data to be saved.
     */
    func saveDataToCache(newData: DATA?) -> AnyPublisher<Void, Never>
}
