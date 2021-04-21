//
//  GithubRepository.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubRepository {

    func followMeta() -> AnyPublisher<State<GithubMeta>, Never> {
        let githubMetaFlowable = GithubMetaFlowableCallback().create()
        return githubMetaFlowable.publish()
    }

    func refreshMeta() -> AnyPublisher<Void, Never> {
        let githubMetaFlowable = GithubMetaFlowableCallback().create()
        return githubMetaFlowable.refresh()
    }

    func followOrgs() -> AnyPublisher<State<[GithubOrg]>, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableCallback().create()
        return githubOrgsFlowable.publish()
    }

    func refreshOrgs() -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableCallback().create()
        return githubOrgsFlowable.refresh()
    }

    func requestAdditionalOrgs(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableCallback().create()
        return githubOrgsFlowable.requestAdditionalData(continueWhenError: continueWhenError)
    }

    func followUser(userName: String) -> AnyPublisher<State<GithubUser>, Never> {
        let githubUserFlowable = GithubUserFlowableCallback(userName: userName).create()
        return githubUserFlowable.publish()
    }

    func refreshUser(userName: String) -> AnyPublisher<Void, Never> {
        let githubUserFlowable = GithubUserFlowableCallback(userName: userName).create()
        return githubUserFlowable.refresh()
    }

    func followRepos(userName: String) -> AnyPublisher<State<[GithubRepo]>, Never> {
        let githubReposFlowable = GithubReposFlowableCallback(userName: userName).create()
        return githubReposFlowable.publish()
    }

    func refreshRepos(userName: String) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubReposFlowableCallback(userName: userName).create()
        return githubReposFlowable.refresh()
    }

    func requestAdditionalRepos(userName: String, continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubReposFlowableCallback(userName: userName).create()
        return githubReposFlowable.requestAdditionalData(continueWhenError: continueWhenError)
    }
}
