//
//  GithubOrgsRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubOrgsRepository {

    func follow() -> LoadingStatePublisher<[GithubOrg]> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.publish()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.requestNextData(continueWhenError: continueWhenError)
    }
}
