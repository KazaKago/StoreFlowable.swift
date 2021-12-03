//
//  GithubUserFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine
import StoreFlowable

struct GithubUserFlowableFactory: StoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = GithubUser

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubUserStateManager.shared

    func loadDataFromCache(param: String) -> AnyPublisher<GithubUser?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.userCache[param]))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: GithubUser?, param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.userCache[param] = newData
            GithubInMemoryCache.userCacheCreatedAt[param] = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin(param: String) -> AnyPublisher<GithubUser, Error> {
        githubApi.getUser(userName: param)
    }

    func needRefresh(cachedData: GithubUser, param: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.userCacheCreatedAt[param] {
                let expiredAt = createdAt + GithubUserFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
