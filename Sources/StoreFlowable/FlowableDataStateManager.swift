//
//  FlowableDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

/**
 * This class that controls and holds the state of data.
 *
 * Does not handle the raw data in this class.
 */
open class FlowableDataStateManager<KEY: Hashable>: FlowAccessor, DataStateManager {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    typealias KEY = KEY

    private var dataState: [KEY: CurrentValueSubject<DataState, Never>] = [:]

    public init() {
    }

    /**
     * Get the data state as `Publisher`.
     *
     * - parameter key: Key to get the specified data.
     * - returns: Flow for getting data state changes.
     */
    func getFlow(key: KEY) -> AnyPublisher<DataState, Never> {
        dataState.getOrCreate(key).eraseToAnyPublisher()
    }

    /**
     * Get the current data state.
     *
     * - parameter key: Key to get the specified data.
     * - returns: State of saved data.
     */
    func loadState(key: KEY) -> DataState {
        dataState.getOrCreate(key).value
    }

    /**
     * Save the data state.
     *
     * - parameter key: Key to get the specified data.
     * - parameter state: State of saved data.
     */
    func saveState(key: KEY, state: DataState) {
        dataState.getOrCreate(key).value = state
    }

    /**
     * Clear all data state in this manager.
     */
    func clearAll() {
        dataState = [:]
    }
}

private extension Dictionary where Key: Hashable, Value == CurrentValueSubject<DataState, Never> {
    mutating func getOrCreate(_ key: Key) -> CurrentValueSubject<DataState, Never> {
        getOrPut(key) {
            CurrentValueSubject<DataState, Never>(DataState.fixed())
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
