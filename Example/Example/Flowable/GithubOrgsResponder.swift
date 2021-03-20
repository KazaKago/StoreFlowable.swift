//
//  GithubOrgsResponder.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import Combine
import StoreFlowable

struct GithubOrgsResponder : PagingStoreFlowableResponder {

    typealias KEY = UnitHash
    typealias DATA = GithubOrg

    private static let EXPIRE_SECONDS = TimeInterval(30)
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = GithubMetaStateManager.shared

    func loadData() -> AnyPublisher<[GithubOrg]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.orgsCache))
        }.eraseToAnyPublisher()
    }

    func saveData(data: [GithubOrg]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.orgsCache = data
            if !additionalRequest { GithubInMemoryCache.orgsCacheCreatedAt = Date() }
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchOrigin(data: [GithubOrg]?, additionalRequest: Bool) -> AnyPublisher<[GithubOrg], Error> {
        let since = additionalRequest ? data?.last?.id : nil
        return githubApi.getOrgs(since: since, perPage: GithubOrgsResponder.PER_PAGE)
    }

    func needRefresh(data: [GithubOrg]) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.orgsCacheCreatedAt {
                let expiredAt = createdAt + GithubOrgsResponder.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
