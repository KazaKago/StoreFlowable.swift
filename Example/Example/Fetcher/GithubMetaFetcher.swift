//
//  GithubMetaFetcher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import StoreFlowable

struct GithubMetaFetcher: Fetcher {

    typealias PARAM = UnitHash
    typealias DATA = GithubMeta

    private let githubApi = GithubApi()

    func fetch(param: UnitHash) async throws -> GithubMeta {
        try await githubApi.getMeta()
    }
}
