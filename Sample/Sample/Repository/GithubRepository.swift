//
//  GithubRepository.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubRepository {

    func followMeta() -> AnyPublisher<State<GithubMeta>, Never> {
        let githubMetaFlowable = GithubMetaResponder().create()
        return githubMetaFlowable.asFlow()
    }

    func refreshMeta() -> AnyPublisher<Void, Never> {
        let githubMetaFlowable = GithubMetaResponder().create()
        return githubMetaFlowable.refresh()
    }

    func followOrgs() -> AnyPublisher<State<[GithubOrg]>, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.asFlow()
    }

    func refreshOrgs() -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.refresh()
    }

    func requestAdditionalOrgs(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.requestAdditional(continueWhenError: continueWhenError)
    }

    func followUser(userName: String) -> AnyPublisher<State<GithubUser>, Never> {
        let githubUserFlowable = GithubUserResponder(key: userName).create()
        return githubUserFlowable.asFlow()
    }

    func refreshUser(userName: String) -> AnyPublisher<Void, Never> {
        let githubUserFlowable = GithubUserResponder(key: userName).create()
        return githubUserFlowable.refresh()
    }
}
