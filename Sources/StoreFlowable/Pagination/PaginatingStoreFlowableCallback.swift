//
//  PaginatingStoreFlowableCallback.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public protocol PaginatingStoreFlowableCallback: PaginatingCacheDataManager, PaginatingOriginDataManager {

    associatedtype KEY: Hashable
    associatedtype DATA

    var key: KEY { get }

    var flowableDataStateManager: FlowableDataStateManager<KEY> { get }

    func needRefresh(cachedData: DATA) -> AnyPublisher<Bool, Never>
}
