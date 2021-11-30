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
open class FlowableDataStateManager<PARAM: Hashable>: FlowAccessor, DataStateManager {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    typealias PARAM = PARAM

    private var dataState: [PARAM: CurrentValueSubject<DataState, Never>] = [:]

    public init() {
    }

    /**
     * Get the data state as `Publisher`.
     *
     * - parameter key: Key to get the specified data.
     * - returns: Flow for getting data state changes.
     */
    func getFlow(param: PARAM) -> AnyPublisher<DataState, Never> {
        dataState.getOrCreate(param).eraseToAnyPublisher()
    }

    /**
     * Get the current data state.
     *
     * - parameter key: Key to get the specified data.
     * - returns: State of saved data.
     */
    func load(param: PARAM) -> DataState {
        dataState.getOrCreate(param).value
    }

    /**
     * Save the data state.
     *
     * - parameter key: Key to get the specified data.
     * - parameter state: State of saved data.
     */
    func save(param: PARAM, state: DataState) {
        dataState.getOrCreate(param).value = state
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
            CurrentValueSubject<DataState, Never>(DataState.fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData, isInitial: true))
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
