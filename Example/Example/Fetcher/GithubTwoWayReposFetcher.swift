//
//  GithubTwoWayReposFetcher.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

struct GithubTwoWayReposFetcher: TwoWayPaginationFetcher {

    typealias PARAM = String
    typealias DATA = GithubRepo

    private static let INITIAL_PAGE = 4
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    func fetch(param: String) async throws -> Fetched.Initial<GithubRepo> {
        let newData = try await githubApi.getRepos(userName: param, page: 4, perPage: Self.PER_PAGE)
        return Fetched.Initial(
            data: newData,
            nextRequestKey: newData.isEmpty ? nil : 5.description,
            prevRequestKey: newData.isEmpty ? nil : 3.description
        )
    }

    func fetchNext(nextKey: String, param: String) async throws -> Fetched.Next<GithubRepo> {
        let nextPage = Int(nextKey)!
        let newData = try await githubApi.getRepos(userName: param, page: nextPage, perPage: Self.PER_PAGE)
        return Fetched.Next(
            data: newData,
            nextRequestKey: newData.isEmpty ? nil : (nextPage + 1).description
        )
    }

    func fetchPrev(prevKey: String, param: String) async throws -> Fetched.Prev<GithubRepo> {
        let prevPage = Int(prevKey)!
        let newData = try await githubApi.getRepos(userName: param, page: prevPage, perPage: Self.PER_PAGE)
        return Fetched.Prev(
            data: newData,
            prevRequestKey: (prevPage > 1) ? (prevPage - 1).description : nil
        )
    }
}
