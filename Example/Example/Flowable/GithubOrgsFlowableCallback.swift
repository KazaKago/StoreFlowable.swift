//
//  GithubOrgsFlowableCallback.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import Combine
import StoreFlowable

struct GithubOrgsFlowableCallback: PaginatingStoreFlowableCallback {

    typealias KEY = UnitHash
    typealias DATA = [GithubOrg]

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadDataFromCache() -> AnyPublisher<[GithubOrg]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.orgsCache))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: [GithubOrg]?) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = newData
            GithubInMemoryCache.orgsCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func saveAdditionalDataToCache(cachedData: [GithubOrg]?, newData: [GithubOrg]) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = (cachedData ?? []) + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<[GithubOrg]>, Error> {
        githubApi.getOrgs(since: nil, perPage: GithubOrgsFlowableCallback.PER_PAGE).map { data in
            FetchingResult(data: data, noMoreAdditionalData: data.isEmpty)
        }.eraseToAnyPublisher()
    }

    func fetchAdditionalDataFromOrigin(cachedData: [GithubOrg]?) -> AnyPublisher<FetchingResult<[GithubOrg]>, Error> {
        let since = cachedData?.last?.id ?? nil
        return githubApi.getOrgs(since: since, perPage: GithubOrgsFlowableCallback.PER_PAGE).map { data in
            FetchingResult(data: data, noMoreAdditionalData: data.isEmpty)
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubOrg]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.orgsCacheCreatedAt {
                let expiredAt = createdAt + GithubOrgsFlowableCallback.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
