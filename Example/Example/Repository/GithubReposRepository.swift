//
//  GithubReposRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubReposRepository {

    func follow(userName: String) -> LoadingStatePublisher<[GithubRepo]> {
        let githubReposFlowable = GithubReposFlowableFactory().create(userName)
        return githubReposFlowable.publish()
    }

    func refresh(userName: String) async {
        let githubReposFlowable = GithubReposFlowableFactory().create(userName)
        await githubReposFlowable.refresh()
    }

    func requestNext(userName: String, continueWhenError: Bool) async {
        let githubReposFlowable = GithubReposFlowableFactory().create(userName)
        await githubReposFlowable.requestNextData(continueWhenError: continueWhenError)
    }
}
