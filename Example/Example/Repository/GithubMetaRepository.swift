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
        let githubMetaFlowable = GithubMetaFlowableFactory().create(UnitHash())
        return githubMetaFlowable.publish()
    }

    func refresh() async {
        let githubMetaFlowable = GithubMetaFlowableFactory().create(UnitHash())
        await githubMetaFlowable.refresh()
    }
}
