//
//  CacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

protocol CacheDataManager {

    associatedtype DATA

    func load() -> AnyPublisher<DATA?, Never>

    func save(newData: DATA?) -> AnyPublisher<Void, Never>
    
    func saveNext(cachedData: DATA, newData: DATA) -> AnyPublisher<Void, Never>

    func savePrev(cachedData: DATA, newData: DATA) -> AnyPublisher<Void, Never>
}
