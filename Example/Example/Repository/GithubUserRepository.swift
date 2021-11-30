//
//  GithubUserRepository.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubUserRepository {

    func follow(userName: String) -> LoadingStatePublisher<GithubUser> {
        let githubUserFlowable = GithubUserFlowableFactory().create(userName)
        return githubUserFlowable.publish()
    }

    func refresh(userName: String) -> AnyPublisher<Void, Never> {
        let githubUserFlowable = GithubUserFlowableFactory().create(userName)
        return githubUserFlowable.refresh()
    }
}
