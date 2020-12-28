//
//  GithubUserResponder.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine
import StoreFlowable

struct GithubUserResponder : StoreFlowableResponder {

    typealias KEY = String
    typealias DATA = GithubUser

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private let githubApi = GithubApi()

    let key: String

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubUserStateManager.shared

    func loadData() -> AnyPublisher<GithubUser?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.userCache[key]))
        }.eraseToAnyPublisher()
    }

    func saveData(data: GithubUser?) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.userCache[key] = data
            GithubInMemoryCache.userCacheCreatedAt[key] = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchOrigin() -> AnyPublisher<GithubUser, Error> {
        githubApi.getUser(userName: key)
    }

    func needRefresh(data: GithubUser) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.userCacheCreatedAt[key] {
                promise(.success(createdAt + GithubUserResponder.EXPIRE_SECONDS < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
