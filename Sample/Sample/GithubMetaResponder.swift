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
    typealias KEY = String
    typealias DATA = GithubMeta

    private let githubApi = GithubApi()

    var key: String

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubMetaStateManager.sharedInstance

    func loadData() -> AnyPublisher<GithubMeta?, Error> {
        Future { promise in
            promise(.success(GithubInMemoryCache.metaCache))
        }.eraseToAnyPublisher()
    }

    func saveData(data: GithubMeta?) -> AnyPublisher<Void, Error> {
        Future { promise in
            GithubInMemoryCache.metaCache = data
            GithubInMemoryCache.metaCacheCreatedAt = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchOrigin() -> AnyPublisher<GithubMeta, Error> {
        githubApi.getMeta()
    }

    func needRefresh(data: GithubMeta) -> AnyPublisher<Bool, Error> {
        Future { promise in
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
}
