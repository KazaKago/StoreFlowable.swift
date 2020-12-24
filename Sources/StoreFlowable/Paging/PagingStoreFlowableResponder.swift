//
//  PagingStoreFlowableResponder.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine

public protocol PagingStoreFlowableResponder: PagingCacheDataManager, PagingOriginDataManager {

    associatedtype KEY: Hashable
    associatedtype DATA

    var key: KEY { get }

    var flowableDataStateManager: FlowableDataStateManager<KEY> { get }

    func loadData() -> AnyPublisher<[DATA]?, Never>

    func saveData(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<Void, Never>

    func fetchOrigin(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<[DATA], Error>

    func needRefresh(data: [DATA]) -> AnyPublisher<Bool, Never>
}
