//
//  GithubReposFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import StoreFlowable

struct GithubReposFlowableFactory: PaginationStoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = [GithubRepo]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubReposStateManager.shared

    func loadDataFromCache(param: String) async -> [GithubRepo]? {
        GithubInMemoryCache.reposCache[param]
    }

    func saveDataToCache(newData: [GithubRepo]?, param: String) async {
        GithubInMemoryCache.reposCache[param] = newData
        GithubInMemoryCache.reposCacheCreatedAt[param] = Date()
    }

    func saveNextDataToCache(cachedData: [GithubRepo], newData: [GithubRepo], param: String) async {
        GithubInMemoryCache.reposCache[param] = cachedData + newData
    }

    func fetchDataFromOrigin(param: String) async throws -> Fetched<[GithubRepo]> {
        let newData = try await githubApi.getRepos(userName: param, page: 1, perPage: GithubReposFlowableFactory.PER_PAGE)
        return Fetched(
            data: newData,
            nextKey: 2.description
        )
    }

    func fetchNextDataFromOrigin(nextKey: String, param: String) async throws -> Fetched<[GithubRepo]> {
        let nextPage = Int(nextKey)!
        let newData = try await githubApi.getRepos(userName: param, page: nextPage, perPage: GithubReposFlowableFactory.PER_PAGE)
        return Fetched(
            data: newData,
            nextKey: newData.isEmpty ? nil : (nextPage + 1).description
        )
    }

    func needRefresh(cachedData: [GithubRepo], param: String) async -> Bool {
        if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[param] {
            let expiredAt = createdAt + GithubReposFlowableFactory.EXPIRE_SECONDS
            return expiredAt < Date()
        } else {
            return true
        }
    }
}
