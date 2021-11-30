//
//  GithubReposFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import Combine
import StoreFlowable

struct GithubReposFlowableFactory: PaginationStoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = [GithubRepo]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubReposStateManager.shared

    func loadDataFromCache(param: String) -> AnyPublisher<[GithubRepo]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.reposCache[param]))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: [GithubRepo]?, param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[param] = newData
            GithubInMemoryCache.reposCacheCreatedAt[param] = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func saveNextDataToCache(cachedData: [GithubRepo], newData: [GithubRepo], param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[param] = cachedData + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin(param: String) -> AnyPublisher<Fetched<[GithubRepo]>, Error> {
        githubApi.getRepos(userName: param, page: 1, perPage: GithubReposFlowableFactory.PER_PAGE).map { newData in
            Fetched(
                data: newData,
                nextKey: 2.description
            )
        }.eraseToAnyPublisher()
    }

    func fetchNextDataFromOrigin(nextKey: String, param: String) -> AnyPublisher<Fetched<[GithubRepo]>, Error> {
        let nextPage = Int(nextKey)!
        return githubApi.getRepos(userName: param, page: nextPage, perPage: GithubReposFlowableFactory.PER_PAGE).map { newData in
            Fetched(
                data: newData,
                nextKey: newData.isEmpty ? nil : (nextPage + 1).description
            )
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubRepo], param: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[param] {
                let expiredAt = createdAt + GithubReposFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
