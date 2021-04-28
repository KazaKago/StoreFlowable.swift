//
//  PaginatingStoreFlowableCallback.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

/**
 * Callback class used from `PaginatingStoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol PaginatingStoreFlowableCallback: StoreFlowableCallback, PaginatingCacheDataManager, PaginatingOriginDataManager {}
