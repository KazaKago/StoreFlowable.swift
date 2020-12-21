//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

public extension StoreFlowableResponder {

    func createStoreFlowable() -> AnyStoreFlowable<KEY, DATA> {
        AnyStoreFlowable(StoreFlowableImpl(storeFlowableResponder: AnyStoreFlowableResponder(self)))
    }
}