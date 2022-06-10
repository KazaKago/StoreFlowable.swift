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
    public let expireSeconds: TimeInterval = TimeInterval.infinity

    public init() {
    }

    public func loadData(param: PARAM) async -> DATA? {
        dataMap[param]
    }

    /**
     * The data saving process to cache.
     *
     * @param data Data to be saved.
     * @param param Key to get the specified data.
     */
    public func saveData(data: DATA?, param: PARAM) async {
        dataMap[param] = data
    }

    /**
     * Gets the time when the data was cached.
     * The format is Epoch Time.
     *
     * @param param Key to get the specified data.
     */
    public func loadDataCachedAt(param: PARAM) async -> Double? {
        dataCachedAtMap[param]
    }

    /**
     * Saves the time when the data was cached.
     *
     * @param epochSeconds Time when the data was cached.
     * @param param Key to get the specified data.
     */
    public func saveDataCachedAt(epochSeconds: Double, param: PARAM) async {
        dataCachedAtMap[param] = epochSeconds
    }

    /**
     * Determine if the cache is valid.
     *
     * @param cachedData Current cache data.
     * @return Returns `true` if the cache is invalid and refresh is needed.
     */
    public func needRefresh(cachedData: DATA, param: PARAM) async -> Bool {
        let cachedAt = await loadDataCachedAt(param: param)
        if let cachedAt = cachedAt {
            let expiredAt = cachedAt + expireSeconds
            return expiredAt < Date().timeIntervalSince1970
        } else {
            return false
        }
    }

    /**
     * Get the data state as [Flow].
     *
     * @param param Key to get the specified data.
     * @return Flow for getting data state changes.
     */
    public func getStateFlow(param: PARAM) -> AnyAsyncSequence<DataState> {
        dataStateMap.getOrCreate(param).eraseToAnyAsyncSequence()
    }

    /**
     * Get the current data state.
     *
     * @param param Key to get the specified data.
     * @return State of saved data.
     */
    public func loadState(param: PARAM) -> DataState {
        dataStateMap.getOrCreate(param).element
    }

    /**
     * Save the data state.
     *
     * @param param Key to get the specified data.
     * @param state State of saved data.
     */
    public func saveState(param: PARAM, state: DataState) {
        dataStateMap.getOrCreate(param).element = state
    }

    /**
     * Clear cache.
     */
    public func clear() {
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
