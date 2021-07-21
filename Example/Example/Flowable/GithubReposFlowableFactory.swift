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

    typealias KEY = String
    typealias DATA = [GithubRepo]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    init(userName: String) {
        key = userName
    }

    let key: String

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubReposStateManager.shared

    func loadDataFromCache() -> AnyPublisher<[GithubRepo]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.reposCache[key]))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: [GithubRepo]?) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[key] = newData
            GithubInMemoryCache.reposCacheCreatedAt[key] = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func saveNextDataToCache(cachedData: [GithubRepo], newData: [GithubRepo]) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[key] = cachedData + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin() -> AnyPublisher<Fetched<[GithubRepo]>, Error> {
        githubApi.getRepos(userName: key, page: 1, perPage: GithubReposFlowableFactory.PER_PAGE).map { newData in
            Fetched(
                data: newData,
                nextKey: 2.description
            )
        }.eraseToAnyPublisher()
    }

    func fetchNextDataFromOrigin(nextKey: String) -> AnyPublisher<Fetched<[GithubRepo]>, Error> {
        let nextPage = Int(nextKey)!
        return githubApi.getRepos(userName: key, page: nextPage, perPage: GithubReposFlowableFactory.PER_PAGE).map { newData in
            Fetched(
                data: newData,
                nextKey: newData.isEmpty ? nil : (nextPage + 1).description
            )
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubRepo]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[key] {
                let expiredAt = createdAt + GithubReposFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
