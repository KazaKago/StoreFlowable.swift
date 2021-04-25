//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

public extension StoreFlowableCallback {

    /**
     * Create `StoreFlowable` class from `StoreFlowableCallback`.
     *
     * - returns: Created StateFlowable.
     */
    func create() -> AnyStoreFlowable<KEY, DATA> {
        AnyStoreFlowable(StoreFlowableImpl(storeFlowableCallback: AnyStoreFlowableCallback(self)))
    }
}
