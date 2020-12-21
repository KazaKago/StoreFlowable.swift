//
//  FlowableDataStateManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

open class FlowableDataStateManager<KEY: Hashable>: FlowAccessor, DataStateManager {

    typealias KEY = KEY

    private var dataState: [KEY: CurrentValueSubject<DataState, Never>] = [:]

    public init() {
    }

    func getFlow(key: KEY) -> AnyPublisher<DataState, Never> {
        dataState.getOrCreate(key).eraseToAnyPublisher()
    }

    func loadState(key: KEY) -> DataState {
        dataState.getOrCreate(key).value
    }

    func saveState(key: KEY, state: DataState) {
        dataState.getOrCreate(key).value = state
    }

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
