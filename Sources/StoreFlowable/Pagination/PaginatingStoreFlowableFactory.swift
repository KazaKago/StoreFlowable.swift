//
//  PaginatingStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

/**
 * Abstract factory class for `PaginatingStoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol PaginatingStoreFlowableFactory: StoreFlowableFactory, PaginatingCacheDataManager, PaginatingOriginDataManager {}
