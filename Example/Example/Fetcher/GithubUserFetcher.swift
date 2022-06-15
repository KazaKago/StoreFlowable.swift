//
//  GithubUserFetcher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import StoreFlowable

struct GithubUserFetcher: Fetcher {

    typealias PARAM = String
    typealias DATA = GithubUser

    private let githubApi = GithubApi()

    func fetch(param: String) async throws -> GithubUser {
        try await githubApi.getUser(userName: param)
    }
}
