//
//  OriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol OriginDataManager {

    associatedtype DATA

    func fetch() async throws -> InternalFetched<DATA>
    
    func fetchNext(nextKey: String) async throws -> InternalFetched<DATA>

    func fetchPrev(prevKey: String) async throws -> InternalFetched<DATA>
}
