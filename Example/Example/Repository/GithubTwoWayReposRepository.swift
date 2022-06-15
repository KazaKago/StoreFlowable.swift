//
//  GithubTwoWayReposRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

struct GithubTwoWayReposRepository {

    func follow() -> LoadingStateSequence<[GithubRepo]> {
        let githubReposFlowable = AnyStoreFlowable.from(cacher: GithubTwoWayReposCacher.shared, fetcher: GithubTwoWayReposFetcher(), param: "github")
        return githubReposFlowable.publish()
    }

    func refresh() async {
        let githubReposFlowable = AnyStoreFlowable.from(cacher: GithubTwoWayReposCacher.shared, fetcher: GithubTwoWayReposFetcher(), param: "github")
        await githubReposFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) async {
        let githubReposFlowable = AnyStoreFlowable.from(cacher: GithubTwoWayReposCacher.shared, fetcher: GithubTwoWayReposFetcher(), param: "github")
        await githubReposFlowable.requestNextData(continueWhenError: continueWhenError)
    }

    func requestPrev(continueWhenError: Bool) async {
        let githubReposFlowable = AnyStoreFlowable.from(cacher: GithubTwoWayReposCacher.shared, fetcher: GithubTwoWayReposFetcher(), param: "github")
        await githubReposFlowable.requestPrevData(continueWhenError: continueWhenError)
    }
}
