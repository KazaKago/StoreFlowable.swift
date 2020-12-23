//
//  PagingCacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PagingCacheDataManager {

    associatedtype DATA

    func loadData() -> AnyPublisher<[DATA]?, Never>

    func saveData(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<Void, Never>
}
