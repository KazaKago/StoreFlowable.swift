//
//  GithubOrgsFetcher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import StoreFlowable

struct GithubOrgsFetcher: PaginationFetcher {

    typealias PARAM = UnitHash
    typealias DATA = GithubOrg

    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    func fetch(param: UnitHash) async throws -> PaginationFetcher.Result<GithubOrg> {
        let data = try await githubApi.getOrgs(since: nil, perPage: Self.PER_PAGE)
        return PaginationFetcher.Result(
            data: data,
            nextRequestKey: data.last?.id.description
        )
    }

    func fetchNext(nextKey: String, param: UnitHash) async throws -> PaginationFetcher.Result<GithubOrg> {
        let data = try await githubApi.getOrgs(since: Int(nextKey), perPage: Self.PER_PAGE)
        return PaginationFetcher.Result(
            data: data,
            nextRequestKey: data.last?.id.description
        )
    }
}
