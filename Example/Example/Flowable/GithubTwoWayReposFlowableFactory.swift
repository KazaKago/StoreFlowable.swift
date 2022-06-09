//
//  GithubTwoWayReposFlowableFactory.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

struct GithubTwoWayReposFlowableFactory: TwoWayPaginationStoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = [GithubRepo]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let INITIAL_PAGE = 4
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubTwoWayReposStateManager.shared

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
    
    func savePrevDataToCache(cachedData: [GithubRepo], newData: [GithubRepo], param: String) async {
        GithubInMemoryCache.reposCache[param] = newData + cachedData
    }

    func fetchDataFromOrigin(param: String) async throws -> FetchedInitial<[GithubRepo]> {
        let newData = try await githubApi.getRepos(userName: param, page: 4, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE)
        return FetchedInitial(
            data: newData,
            nextKey: newData.isEmpty ? nil : 5.description,
            prevKey: newData.isEmpty ? nil : 3.description
        )
    }

    func fetchNextDataFromOrigin(nextKey: String, param: String) async throws -> FetchedNext<[GithubRepo]> {
        let nextPage = Int(nextKey)!
        let newData = try await githubApi.getRepos(userName: param, page: nextPage, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE)
        return FetchedNext(
            data: newData,
            nextKey: newData.isEmpty ? nil : (nextPage + 1).description
        )
    }

    func fetchPrevDataFromOrigin(prevKey: String, param: String) async throws -> FetchedPrev<[GithubRepo]> {
        let prevPage = Int(prevKey)!
        let newData = try await githubApi.getRepos(userName: param, page: prevPage, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE)
        return FetchedPrev(
            data: newData,
            prevKey: (prevPage > 1) ? (prevPage - 1).description : nil
        )
    }

    func needRefresh(cachedData: [GithubRepo], param: String) async -> Bool {
        if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[param] {
            let expiredAt = createdAt + GithubTwoWayReposFlowableFactory.EXPIRE_SECONDS
            return expiredAt < Date()
        } else {
            return true
        }
    }
}
