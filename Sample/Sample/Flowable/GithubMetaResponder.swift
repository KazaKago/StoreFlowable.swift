//
//  GithubMetaResponder.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine
import StoreFlowable

struct GithubMetaResponder : StoreFlowableResponder {

    typealias KEY = UnitHash
    typealias DATA = GithubMeta

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private let githubApi = GithubApi()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadData() -> AnyPublisher<GithubMeta?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.metaCache))
        }.eraseToAnyPublisher()
    }

    func saveData(data: GithubMeta?) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.metaCache = data
            GithubInMemoryCache.metaCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchOrigin() -> AnyPublisher<GithubMeta, Error> {
        githubApi.getMeta()
    }

    func needRefresh(data: GithubMeta) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.metaCacheCreatedAt {
                promise(.success(createdAt + GithubMetaResponder.EXPIRE_SECONDS < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
