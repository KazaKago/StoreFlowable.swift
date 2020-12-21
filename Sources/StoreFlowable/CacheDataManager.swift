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

    func loadData() -> AnyPublisher<DATA?, Never>

    func saveData(data: DATA?) -> AnyPublisher<Void, Never>
}
