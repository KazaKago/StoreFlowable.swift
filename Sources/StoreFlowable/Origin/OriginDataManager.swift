//
//  OriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

protocol OriginDataManager {

    associatedtype DATA

    func fetch() -> AnyPublisher<InternalFetched<DATA>, Error>
    
    func fetchNext(nextKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>

    func fetchPrev(prevKey: String) -> AnyPublisher<InternalFetched<DATA>, Error>
}
