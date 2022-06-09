//
//  FlowableDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import AsyncExtensions

/**
 * This class that controls and holds the state of data.
 *
 * Does not handle the raw data in this class.
 */
open class FlowableDataStateManager<PARAM: Hashable> {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    typealias PARAM = PARAM

    private var dataState: [PARAM: AsyncStreams.CurrentValue<DataState>] = [:]
    private var nextKey: [PARAM: String] = [:]
    private var prevKey: [PARAM: String] = [:]

    public init() {
    }

    /**
     * Get the data state as `Publisher`.
     *
     * - parameter key: Key to get the specified data.
     * - returns: Flow for getting data state changes.
     */
    func getFlow(param: PARAM) -> AnyAsyncSequence<DataState> {
        dataState.getOrCreate(param).eraseToAnyAsyncSequence()
    }

    /**
     * Get the current data state.
     *
     * - parameter key: Key to get the specified data.
     * - returns: State of saved data.
     */
    func load(param: PARAM) -> DataState {
        dataState.getOrCreate(param).element
    }

    /**
     * Save the data state.
     *
     * - parameter key: Key to get the specified data.
     * - parameter state: State of saved data.
     */
    func save(param: PARAM, state: DataState) {
        dataState.getOrCreate(param).element = state
    }

    /**
     * Clear all data state in this manager.
     */
    func clearAll() {
        dataState = [:]
    }
    
    func loadNext(param: PARAM) -> String? {
        nextKey[param]
    }

    func saveNext(param: PARAM, requestKey: String?) {
        nextKey[param] = requestKey
    }

    func loadPrev(param: PARAM) -> String? {
        prevKey[param]
    }

    func savePrev(param: PARAM, requestKey: String?) {
        prevKey[param] = requestKey
    }
}

private extension Dictionary where Key: Hashable, Value == AsyncStreams.CurrentValue<DataState> {
    mutating func getOrCreate(_ key: Key) -> AsyncStreams.CurrentValue<DataState> {
        getOrPut(key) {
            AsyncStreams.CurrentValue<DataState>(DataState.fixed(nextDataState: .fixed, prevDataState: .fixed))
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
