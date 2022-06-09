//
//  GithubOrgsFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import StoreFlowable

struct GithubOrgsFlowableFactory: PaginationStoreFlowableFactory {

    typealias PARAM = UnitHash
    typealias DATA = [GithubOrg]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubOrgsStateManager.shared

    func loadDataFromCache(param: UnitHash) async -> [GithubOrg]? {
        GithubInMemoryCache.orgsCache
    }

    func saveDataToCache(newData: [GithubOrg]?, param: UnitHash) async {
        GithubInMemoryCache.orgsCache = newData
        GithubInMemoryCache.orgsCacheCreatedAt = Date()
    }

    func saveNextDataToCache(cachedData: [GithubOrg], newData: [GithubOrg], param: UnitHash) async {
        GithubInMemoryCache.orgsCache = cachedData + newData
    }

    func fetchDataFromOrigin(param: UnitHash) async throws -> Fetched<[GithubOrg]> {
        let data = try await githubApi.getOrgs(since: nil, perPage: GithubOrgsFlowableFactory.PER_PAGE)
        return Fetched(
            data: data,
            nextKey: data.last?.id.description
        )
    }

    func fetchNextDataFromOrigin(nextKey: String, param: UnitHash) async throws -> Fetched<[GithubOrg]> {
        let data = try await githubApi.getOrgs(since: Int(nextKey), perPage: GithubOrgsFlowableFactory.PER_PAGE)
        return Fetched(
            data: data,
            nextKey: data.last?.id.description
        )
    }

    func needRefresh(cachedData: [GithubOrg], param: UnitHash) async -> Bool {
        if let createdAt = GithubInMemoryCache.orgsCacheCreatedAt {
            let expiredAt = createdAt + GithubOrgsFlowableFactory.EXPIRE_SECONDS
            return expiredAt < Date()
        } else {
            return true
        }
    }
}
