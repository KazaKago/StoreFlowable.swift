//
//  GithubOrgsFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import Combine
import StoreFlowable

struct GithubOrgsFlowableFactory: PaginationStoreFlowableFactory {

    typealias KEY = UnitHash
    typealias DATA = [GithubOrg]

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubOrgsStateManager.shared

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

    func saveNextDataToCache(cachedData: [GithubOrg], newData: [GithubOrg]) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = cachedData + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin() -> AnyPublisher<Fetched<[GithubOrg]>, Error> {
        githubApi.getOrgs(since: nil, perPage: GithubOrgsFlowableFactory.PER_PAGE).map { data in
            Fetched(data: data, nextKey: data.last?.id.description)
        }.eraseToAnyPublisher()
    }

    func fetchNextDataFromOrigin(nextKey: String) -> AnyPublisher<Fetched<[GithubOrg]>, Error> {
        return githubApi.getOrgs(since: Int(nextKey), perPage: GithubOrgsFlowableFactory.PER_PAGE).map { data in
            Fetched(data: data, nextKey: data.last?.id.description)
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubOrg]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.orgsCacheCreatedAt {
                let expiredAt = createdAt + GithubOrgsFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
