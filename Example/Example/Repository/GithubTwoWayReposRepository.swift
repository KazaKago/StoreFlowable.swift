//
//  GithubTwoWayReposRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubTwoWayReposRepository {

    func follow() -> LoadingStatePublisher<[GithubRepo]> {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create("github")
        return githubReposFlowable.publish()
    }

    func refresh() async {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create("github")
        await githubReposFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) async {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create("github")
        await githubReposFlowable.requestNextData(continueWhenError: continueWhenError)
    }

    func requestPrev(continueWhenError: Bool) async {
        let githubReposFlowable = GithubTwoWayReposFlowableFactory().create("github")
        await githubReposFlowable.requestPrevData(continueWhenError: continueWhenError)
    }
}
