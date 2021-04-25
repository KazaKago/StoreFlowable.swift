//
//  PaginatingStoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public extension PaginatingStoreFlowableCallback {

    /**
     * Create `PaginatingStoreFlowable` class from `PaginatingStoreFlowableCallback`.
     *
     * - returns: Created PaginatingStoreFlowable.
     */
    func create() -> AnyPaginatingStoreFlowable<KEY, DATA> {
        AnyPaginatingStoreFlowable(PaginatingStoreFlowableImpl(storeFlowableCallback: AnyPaginatingStoreFlowableCallback(self)))
    }
}
