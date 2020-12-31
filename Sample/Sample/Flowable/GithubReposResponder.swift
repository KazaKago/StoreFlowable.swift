//
//  GithubReposResponder.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import Combine
import StoreFlowable

struct GithubReposResponder : PagingStoreFlowableResponder {

    typealias KEY = String
    typealias DATA = GithubRepo

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    init(userName: String) {
        key = userName
    }

    let key: String

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubReposStateManager.shared

    func loadData() -> AnyPublisher<[GithubRepo]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.reposCache[key]))
        }.eraseToAnyPublisher()
    }

    func saveData(data: [GithubRepo]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[key] = data
            if !additionalRequest { GithubInMemoryCache.reposCacheCreatedAt[key] = Date() }
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchOrigin(data: [GithubRepo]?, additionalRequest: Bool) -> AnyPublisher<[GithubRepo], Error> {
        let since = additionalRequest ? data?.last?.id : nil
        return githubApi.getRepos(userName: key, since: since, perPage: GithubReposResponder.PER_PAGE)
    }

    func needRefresh(data: [GithubRepo]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[key] {
                let expiredAt = createdAt + GithubReposResponder.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
