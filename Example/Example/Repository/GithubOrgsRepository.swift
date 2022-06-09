//
//  GithubOrgsRepository.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubOrgsRepository {

    func follow() -> LoadingStatePublisher<[GithubOrg]> {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create(UnitHash())
        return githubOrgsFlowable.publish()
    }

    func refresh() async {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create(UnitHash())
        await githubOrgsFlowable.refresh()
    }

    func requestNext(continueWhenError: Bool) async {
        let githubOrgsFlowable = GithubOrgsFlowableFactory().create(UnitHash())
        await githubOrgsFlowable.requestNextData(continueWhenError: continueWhenError)
    }
}
