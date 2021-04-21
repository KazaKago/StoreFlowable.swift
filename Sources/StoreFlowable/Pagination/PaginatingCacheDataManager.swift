//
//  PaginatingCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PaginatingCacheDataManager: CacheDataManager {

    func saveAdditionalDataToCache(cachedData: DATA?, newData: DATA) -> AnyPublisher<Void, Never>
}
