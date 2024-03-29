//
//  TwoWayPaginationStoreFlowable.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

/**
 * Provides input / output methods that abstract the data acquisition destination.
 *
 * This class is generated from `TwoWayPaginationStoreFlowableFactory.create`.
 */
public protocol TwoWayPaginationStoreFlowable: PaginationStoreFlowable {

    /**
     * Request previous data.
     *
     * Do nothing if there is no additional data or if already data retrieving.
     *
     * - parameter continueWhenError: Even if the data state is an `LoadingState.error` when `refresh` is called, the refresh will continue. Default value is `true`.
     */
    func requestPrevData(continueWhenError: Bool) async
    
    /**
     * Treat the passed data as the latest acquired data.
     * and the new data will be notified.
     *
     * Use when new data is created or acquired externally.
     *
     * - parameter newData: Latest data.
     * - parameter nextKey: Key for next request. If null is set, the stored key will be used.
     * - parameter prevKey: Key for prev request. If null is set, the stored key will be used.
     */
    func update(newData: DATA?, nextKey: String?, prevKey: String?) async
}

public extension TwoWayPaginationStoreFlowable {

    func requestPrevData(continueWhenError: Bool = true) async {
        await requestPrevData(continueWhenError: continueWhenError)
    }

    func update(newData: DATA?, nextKey: String? = nil, prevKey: String? = nil) async {
        await update(newData: newData, nextKey: nextKey, prevKey: prevKey)
    }
}
