//
//  CacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

public protocol CacheDataManager {

    associatedtype DATA

    func loadDataFromCache() -> AnyPublisher<DATA?, Never>

    func saveDataToCache(newData: DATA?) -> AnyPublisher<Void, Never>
}
