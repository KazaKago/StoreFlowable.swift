//
//  GithubMetaFlowableFactory.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine
import StoreFlowable

struct GithubMetaFlowableFactory: StoreFlowableFactory {

    typealias PARAM = UnitHash
    typealias DATA = GithubMeta

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadDataFromCache(param: UnitHash) -> AnyPublisher<GithubMeta?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.metaCache))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: GithubMeta?, param: UnitHash) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.metaCache = newData
            GithubInMemoryCache.metaCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin(param: UnitHash) -> AnyPublisher<GithubMeta, Error> {
        githubApi.getMeta()
    }

    func needRefresh(cachedData: GithubMeta, param: UnitHash) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.metaCacheCreatedAt {
                let expiredAt = createdAt + GithubMetaFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
