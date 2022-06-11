//
//  GithubOrgsRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

struct GithubOrgsRepository {

    func follow() -> LoadingStatePublisher<[GithubOrg]> {
        let githubOrgsFlowable = AnyStoreFlowable.from(cacher: GithubOrgsCacher.shared, fetcher: GithubOrgsFetcher())
        return githubOrgsFlowable.publish()
    }

    func refresh() async {
        let githubOrgsFlowable = AnyStoreFlowable.from(cacher: GithubOrgsCacher.shared, fetcher: GithubOrgsFetcher())
        await githubOrgsFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) async {
        let githubOrgsFlowable = AnyStoreFlowable.from(cacher: GithubOrgsCacher.shared, fetcher: GithubOrgsFetcher())
        await githubOrgsFlowable.requestNextData(continueWhenError: continueWhenError)
    }
}
