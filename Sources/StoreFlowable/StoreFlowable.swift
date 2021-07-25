//
//  StoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation
import Combine

/**
 * Provides input / output methods that abstract the data acquisition destination.
 *
 * This class is generated from `StoreFlowableFactory.create`.
 */
public protocol StoreFlowable {

    /**
     * Specify the type that is the key to retrieve the data. If there is only one data to handle, specify the `UnitHash` type.
     */
    associatedtype KEY: Hashable
    /**
     * Specify the type of data to be handled.
     */
    associatedtype DATA

    /**
     * Returns a `LoadingStatePublisher` that can continuously receive changes in the state of the data.
     *
     * If the data has not been acquired yet, new data will be automatically acquired when this `Publisher` is sinked.
     *
     * The error when retrieving data is included in `LoadingStatePublisher.error`.
     * and this method itself does not throw an `Error`.
     *
     * - parameter forceRefresh: Set to `true` if you want to forcibly retrieve data from origin when collecting. Default value is `false`.
     * - returns: Returns a `Publisher` containing the state of the data.
     */
    func publish(forceRefresh: Bool) -> LoadingStatePublisher<DATA>

    /**
     * Returns valid data only once.
     *
     * If the data could not be retrieved, it returns nil instead.
     * and this method itself does not throw an `Error`.
     *
     * Use `publish` if the state of your data is likely to change.
     *
     * - parameter from: Specifies where to get the data. Default value is `GettingFrom.both`
     * - returns: Returns the entity of the data.
     */
    func getData(from: GettingFrom) -> AnyPublisher<DATA?, Never>

    /**
     * Returns valid data only once.
     *
     * If the data cannot be acquired, an `Error` will be thrown.
     *
     * Use `publish` if the state of your data is likely to change.
     *
     * - parameter from: Specifies where to get the data. Default value is `GettingFrom.both`.
     * - returns: Returns the entity of the data.
     */
    func requireData(from: GettingFrom) -> AnyPublisher<DATA, Error>

    /**
     * Checks if the published data is valid.
     *
     * If it is invalid, it will be reacquired from origin.
     * and the new data will be notified.
     */
    func validate() -> AnyPublisher<Void, Never>

    /**
     * Forces a data refresh.
     * and the new data will be notified.
     */
    func refresh() -> AnyPublisher<Void, Never>

    /**
     * Treat the passed data as the latest acquired data.
     * and the new data will be notified.
     *
     * Use when new data is created or acquired externally.
     *
     * - parameter newData: Latest data.
     */
    func update(newData: DATA?) -> AnyPublisher<Void, Never>
}

public extension StoreFlowable {

    func publish(forceRefresh: Bool = false) -> LoadingStatePublisher<DATA> {
        publish(forceRefresh: forceRefresh)
    }

    func getData(from: GettingFrom = .both) -> AnyPublisher<DATA?, Never> {
        getData(from: from)
    }

    func requireData(from: GettingFrom = .both) -> AnyPublisher<DATA, Error> {
        requireData(from: from)
    }
}
