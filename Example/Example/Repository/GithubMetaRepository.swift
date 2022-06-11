//
//  GithubMetaRepository.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import StoreFlowable

struct GithubMetaRepository {

    func follow() -> LoadingStatePublisher<GithubMeta> {
        let githubMetaFlowable = AnyStoreFlowable.from(cacher: GithubMetaCacher.shared, fetcher: GithubMetaFetcher())
        return githubMetaFlowable.publish()
    }

    func refresh() async {
        let githubMetaFlowable = AnyStoreFlowable.from(cacher: GithubMetaCacher.shared, fetcher: GithubMetaFetcher())
        await githubMetaFlowable.refresh()
    }
}
