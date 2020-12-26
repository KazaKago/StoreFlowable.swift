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

    func followMeta() -> AnyPublisher<FlowableState<GithubMeta>, Never> {
        let githubMetaFlowable = GithubMetaResponder().create()
        return githubMetaFlowable.asFlow()
    }

    func requestMeta() -> AnyPublisher<Void, Never> {
        let githubMetaFlowable = GithubMetaResponder().create()
        return githubMetaFlowable.request()
    }

    func followOrgs() -> AnyPublisher<FlowableState<[GithubOrg]>, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.asFlow()
    }

    func requestOrgs() -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.request()
    }

    func requestAdditionalOrgs(fetchAtError: Bool) -> AnyPublisher<Void, Never> {
        let githubOrgsFlowable = GithubOrgsResponder().create()
        return githubOrgsFlowable.requestAdditional(fetchAtError: fetchAtError)
    }
}
