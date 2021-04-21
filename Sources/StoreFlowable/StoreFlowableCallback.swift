//
//  StoreFlowableCallback.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/10.
//

import Foundation
import Combine

public protocol StoreFlowableCallback: CacheDataManager, OriginDataManager {

    associatedtype KEY: Hashable
    associatedtype DATA

    var key: KEY { get }

    var flowableDataStateManager: FlowableDataStateManager<KEY> { get }

    func needRefresh(cachedData: DATA) -> AnyPublisher<Bool, Never>
}
