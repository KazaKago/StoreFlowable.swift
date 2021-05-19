//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

public extension StoreFlowableFactory {

    /**
     * Create `StoreFlowable` class from `StoreFlowableFactory`.
     *
     * - returns: Created StateFlowable.
     */
    func create() -> AnyStoreFlowable<KEY, DATA> {
        AnyStoreFlowable(StoreFlowableImpl(
            key: key,
            flowableDataStateManager: flowableDataStateManager,
            cacheDataManager: AnyCacheDataManager(self),
            originDataManager: AnyOriginDataManager(self),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData) }
        ))
    }
}

public extension PaginatingStoreFlowableFactory {

    /**
     * Create `PaginatingStoreFlowable` class from `PaginatingStoreFlowableFactory`.
     *
     * - returns: Created PaginatingStoreFlowable.
     */
    func create() -> AnyPaginatingStoreFlowable<KEY, DATA> {
        AnyPaginatingStoreFlowable(PaginatingStoreFlowableImpl(
            key: key,
            flowableDataStateManager: flowableDataStateManager,
            cacheDataManager: AnyPaginatingCacheDataManager(self),
            originDataManager: AnyPaginatingOriginDataManager(self),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData) }
        ))
    }
}
