//
//  GithubTwoWayReposRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubTwoWayReposRepository {

    func follow() -> LoadingStatePublisher<[GithubRepo]> {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create()
        return githubReposFlowable.publish()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create()
        return githubReposFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create()
        return githubReposFlowable.requestNextData(continueWhenError: continueWhenError)
    }

    func requestPrev(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create()
        return githubReposFlowable.requestPrevData(continueWhenError: continueWhenError)
    }
}
