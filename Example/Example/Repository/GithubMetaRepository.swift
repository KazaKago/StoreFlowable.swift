//
//  GithubMetaRepository.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubMetaRepository {

    func follow() -> LoadingStatePublisher<GithubMeta> {
        let githubMetaFlowable = GithubMetaFlowableFactory().create()
        return githubMetaFlowable.publish()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        let githubMetaFlowable = GithubMetaFlowableFactory().create()
        return githubMetaFlowable.refresh()
    }
}
