//
//  GithubReposFetcher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import StoreFlowable

struct GithubReposFetcher: PaginationFetcher {

    typealias PARAM = String
    typealias DATA = GithubRepo

    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    func fetch(param: String) async throws -> PaginationFetcher.Result<GithubRepo> {
        let newData = try await githubApi.getRepos(userName: param, page: 1, perPage: Self.PER_PAGE)
        return PaginationFetcher.Result(
            data: newData,
            nextRequestKey: 2.description
        )
    }

    func fetchNext(nextKey: String, param: String) async throws -> PaginationFetcher.Result<GithubRepo> {
        let nextPage = Int(nextKey)!
        let newData = try await githubApi.getRepos(userName: param, page: nextPage, perPage: Self.PER_PAGE)
        return PaginationFetcher.Result(
            data: newData,
            nextRequestKey: newData.isEmpty ? nil : (nextPage + 1).description
        )
    }
}
