//
//  StoreFlowableResponder.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/10.
//

import Foundation
import Combine

protocol StoreFlowableResponder: CacheDataManager, OriginDataManager {

    associatedtype KEY: Hashable
    associatedtype DATA

    var key: KEY { get }

    var flowableDataStateManager: FlowableDataStateManager<KEY> { get }

    func loadData() -> AnyPublisher<DATA?, Error>

    func saveData(data: DATA?) -> AnyPublisher<Void, Error>

    func fetchOrigin() -> AnyPublisher<DATA, Error>

    func needRefresh(data: DATA) -> AnyPublisher<Bool, Error>
}
