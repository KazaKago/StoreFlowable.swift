//
//  GithubMetaFlowableCallback.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine
import StoreFlowable

struct GithubMetaFlowableCallback: StoreFlowableCallback {

    typealias KEY = UnitHash
    typealias DATA = GithubMeta

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private let githubApi = GithubApi()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadDataFromCache() -> AnyPublisher<GithubMeta?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.metaCache))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: GithubMeta?) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.metaCache = newData
            GithubInMemoryCache.metaCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<GithubMeta>, Error> {
        githubApi.getMeta().map { data in
            FetchingResult(data: data)
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: GithubMeta) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.metaCacheCreatedAt {
                let expiredAt = createdAt + GithubMetaFlowableCallback.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
