//
//  PaginatingStoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public extension PaginatingStoreFlowableCallback {

    func create() -> AnyPaginatingStoreFlowable<KEY, DATA> {
        AnyPaginatingStoreFlowable(PaginatingStoreFlowableImpl(storeFlowableCallback: AnyPaginatingStoreFlowableCallback(self)))
    }
}
