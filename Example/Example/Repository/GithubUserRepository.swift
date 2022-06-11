//
//  GithubUserRepository.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import StoreFlowable

struct GithubUserRepository {

    func follow(userName: String) -> LoadingStatePublisher<GithubUser> {
        let githubUserFlowable = AnyStoreFlowable.from(cacher: GithubUserCacher.shared, fetcher: GithubUserFetcher(), param: userName)
        return githubUserFlowable.publish()
    }

    func refresh(userName: String) async {
        let githubUserFlowable = AnyStoreFlowable.from(cacher: GithubUserCacher.shared, fetcher: GithubUserFetcher(), param: userName)
        await githubUserFlowable.refresh()
    }
}
