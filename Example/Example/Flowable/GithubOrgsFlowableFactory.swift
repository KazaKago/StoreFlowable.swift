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

    typealias PARAM = UnitHash
    typealias DATA = [GithubOrg]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubOrgsStateManager.shared

    func loadDataFromCache(param: UnitHash) -> AnyPublisher<[GithubOrg]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.orgsCache))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: [GithubOrg]?, param: UnitHash) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = newData
            GithubInMemoryCache.orgsCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func saveNextDataToCache(cachedData: [GithubOrg], newData: [GithubOrg], param: UnitHash) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = cachedData + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin(param: UnitHash) -> AnyPublisher<Fetched<[GithubOrg]>, Error> {
        githubApi.getOrgs(since: nil, perPage: GithubOrgsFlowableFactory.PER_PAGE).map { data in
            Fetched(
                data: data,
                nextKey: data.last?.id.description
            )
        }.eraseToAnyPublisher()
    }

    func fetchNextDataFromOrigin(nextKey: String, param: UnitHash) -> AnyPublisher<Fetched<[GithubOrg]>, Error> {
        return githubApi.getOrgs(since: Int(nextKey), perPage: GithubOrgsFlowableFactory.PER_PAGE).map { data in
            Fetched(
                data: data,
                nextKey: data.last?.id.description
            )
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubOrg], param: UnitHash) -> AnyPublisher<Bool, Never> {
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
