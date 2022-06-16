//
//  Cacher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

import Foundation
import AsyncExtensions

open class Cacher<PARAM: Hashable, DATA> {

    private var dataMap: [PARAM: DATA] = [:]
    private var dataCachedAtMap: [PARAM: Double] = [:]
    private var dataStateMap: [PARAM: AsyncStreams.CurrentValue<DataState>] = [:]

    /**
     * Sets the time to data expire in seconds.
     * default is TimeInterval.infinity (= not expire)
     */
    open var expireSeconds: TimeInterval {
        get { TimeInterval.infinity }
    }

    public init() {
    }

    /**
     * The data loading process from cache.
     *
     * - parameter param: Key to get the specified data.
     * - returns: The loaded data.
     */
    open func loadData(param: PARAM) async -> DATA? {
        dataMap[param]
    }

    /**
     * The data saving process to cache.
     *
     * - parameter data: Data to be saved.
     * - parameter param: Key to get the specified data.
     */
    open func saveData(data: DATA?, param: PARAM) async {
        dataMap[param] = data
    }

    /**
     * Gets the time when the data was cached.
     * The format is Epoch Time.
     *
     * - parameter param: Key to get the specified data.
     * - returns: Epoch seconds.
     */
    open func loadDataCachedAt(param: PARAM) async -> Double? {
        dataCachedAtMap[param]
    }

    /**
     * Saves the time when the data was cached.
     *
     * - parameter epochSeconds: Time when the data was cached.
     * - parameter param: Key to get the specified data.
     */
    open func saveDataCachedAt(epochSeconds: Double, param: PARAM) async {
        dataCachedAtMap[param] = epochSeconds
    }

    /**
     * Determine if the cache is valid.
     *
     * - parameter cachedData: Current cache data.
     * - returns: Returns `true` if the cache is invalid and refresh is needed.
     */
    open func needRefresh(cachedData: DATA, param: PARAM) async -> Bool {
        let cachedAt = await loadDataCachedAt(param: param)
        if let cachedAt = cachedAt {
            let expiredAt = cachedAt + expireSeconds
            return expiredAt < Date().timeIntervalSince1970
        } else {
            return false
        }
    }

    func getStateFlow(param: PARAM) -> AnyAsyncSequence<DataState> {
        dataStateMap.getOrCreate(param).eraseToAnyAsyncSequence()
    }

    func loadState(param: PARAM) -> DataState {
        dataStateMap.getOrCreate(param).element
    }

    func saveState(param: PARAM, state: DataState) {
        dataStateMap.getOrCreate(param).element = state
    }

    /**
     * Clear cache.
     */
    open func clear() {
        dataMap.removeAll()
        dataCachedAtMap.removeAll()
        dataStateMap.removeAll()
    }
}

private extension Dictionary where Key: Hashable, Value == AsyncStreams.CurrentValue<DataState> {
    mutating func getOrCreate(_ key: Key) -> AsyncStreams.CurrentValue<DataState> {
        getOrPut(key) {
            AsyncStreams.CurrentValue<DataState>(.fixed(nextDataState: .fixed, prevDataState: .fixed))
        }
    }
}

private extension Dictionary {
    mutating func getOrPut(_ key: Key, _ defaultValue: () -> Value) -> Value {
        if let value = self[key] {
            return value
        } else {
            let defaultValue = defaultValue()
            self[key] = defaultValue
            return defaultValue
        }
    }
}
