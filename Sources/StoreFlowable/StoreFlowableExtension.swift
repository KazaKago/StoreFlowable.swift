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
        AnyStoreFlowable(StoreFlowableImpl(storeFlowableFactory: AnyStoreFlowableFactory(self)))
    }
}

public extension PaginatingStoreFlowableFactory {

    /**
     * Create `PaginatingStoreFlowable` class from `PaginatingStoreFlowableFactory`.
     *
     * - returns: Created PaginatingStoreFlowable.
     */
    func create() -> AnyPaginatingStoreFlowable<KEY, DATA> {
        AnyPaginatingStoreFlowable(PaginatingStoreFlowableImpl(storeFlowableFactory: AnyPaginatingStoreFlowableFactory(self)))
    }
}
