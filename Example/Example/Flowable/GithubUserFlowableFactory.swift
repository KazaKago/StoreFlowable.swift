//
//  GithubUserFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import StoreFlowable

struct GithubUserFlowableFactory: StoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = GithubUser

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubUserStateManager.shared

    func loadDataFromCache(param: String) async -> GithubUser? {
        GithubInMemoryCache.userCache[param]
    }

    func saveDataToCache(newData: GithubUser?, param: String) async {
        GithubInMemoryCache.userCache[param] = newData
        GithubInMemoryCache.userCacheCreatedAt[param] = Date()
    }

    func fetchDataFromOrigin(param: String) async throws -> GithubUser {
        try await githubApi.getUser(userName: param)
    }

    func needRefresh(cachedData: GithubUser, param: String) async -> Bool {
        if let createdAt = GithubInMemoryCache.userCacheCreatedAt[param] {
            let expiredAt = createdAt + GithubUserFlowableFactory.EXPIRE_SECONDS
            return expiredAt < Date()
        } else {
            return true
        }
    }
}
