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
}
