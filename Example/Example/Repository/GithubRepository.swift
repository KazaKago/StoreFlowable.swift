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

    func followMeta() -> LoadingStatePublisher<GithubMeta> {
        let githubMetaFlowable = GithubMetaFlowableFactory().create()
        return githubMetaFlowable.publish()
    }

    func refreshMeta() -> AnyPublisher<Void, Never> {
        let githubMetaFlowable = GithubMetaFlowableFactory().create()
        return githubMetaFlowable.refresh()
    }

    func followOrgs() -> LoadingStatePublisher<[GithubOrg]> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.publish()
    }

    func refreshOrgs() -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.refresh()
    }

    func requestNextOrgs(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create()
        return githubOrgsFlowable.requestNextData(continueWhenError: continueWhenError)
    }

    func followUser(userName: String) -> LoadingStatePublisher<GithubUser> {
        let githubUserFlowable = GithubUserFlowableFactory(userName: userName).create()
        return githubUserFlowable.publish()
    }

    func refreshUser(userName: String) -> AnyPublisher<Void, Never> {
        let githubUserFlowable = GithubUserFlowableFactory(userName: userName).create()
        return githubUserFlowable.refresh()
    }

    func followRepos(userName: String) -> LoadingStatePublisher<[GithubRepo]> {
        let githubReposFlowable = GithubReposFlowableFactory(userName: userName).create()
        return githubReposFlowable.publish()
    }

    func refreshRepos(userName: String) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubReposFlowableFactory(userName: userName).create()
        return githubReposFlowable.refresh()
    }

    func requestNextRepos(userName: String, continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        let githubReposFlowable = GithubReposFlowableFactory(userName: userName).create()
        return githubReposFlowable.requestNextData(continueWhenError: continueWhenError)
    }
}
