//
//  GithubMetaFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import StoreFlowable

struct GithubMetaFlowableFactory: StoreFlowableFactory {

    typealias PARAM = UnitHash
    typealias DATA = GithubMeta

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadDataFromCache(param: UnitHash) async -> GithubMeta? {
        GithubInMemoryCache.metaCache
    }

    func saveDataToCache(newData: GithubMeta?, param: UnitHash) async {
        GithubInMemoryCache.metaCache = newData
        GithubInMemoryCache.metaCacheCreatedAt = Date()
    }

    func fetchDataFromOrigin(param: UnitHash) async throws -> GithubMeta {
        try await githubApi.getMeta()
    }

    func needRefresh(cachedData: GithubMeta, param: UnitHash) async -> Bool {
        if let createdAt = GithubInMemoryCache.metaCacheCreatedAt {
            let expiredAt = createdAt + GithubMetaFlowableFactory.EXPIRE_SECONDS
            return expiredAt < Date()
        } else {
            return true
        }
    }
}
