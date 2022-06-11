//
//  GithubApi.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Alamofire

struct GithubApi {

    private let baseApiUrl = URL(string: "https://api.github.com/")!

    func getMeta() async throws -> GithubMeta {
        try await AF.request(baseApiUrl.appendingPathComponent("meta").toUrlRequest())
            .publish(GithubMeta.self)
    }

    func getOrgs(since: Int?, perPage: Int) async throws -> [GithubOrg] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "per_page", value: perPage.description))
        if let since = since { queryItems.append(URLQueryItem(name: "since", value: since.description)) }
        var urlComponents = URLComponents(url: baseApiUrl.appendingPathComponent("organizations"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        return try await AF.request((try! urlComponents.asURL()).toUrlRequest())
            .publish([GithubOrg].self)
    }

    func getUser(userName: String) async throws -> GithubUser {
        try await AF.request(baseApiUrl.appendingPathComponent("users/\(userName)").toUrlRequest())
            .publish(GithubUser.self)
    }

    func getRepos(userName: String, page: Int, perPage: Int) async throws -> [GithubRepo] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "per_page", value: perPage.description))
        queryItems.append(URLQueryItem(name: "page", value: page.description))
        var urlComponents = URLComponents(url: baseApiUrl.appendingPathComponent("users/\(userName)/repos"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        return try await AF.request((try! urlComponents.asURL()).toUrlRequest())
            .publish([GithubRepo].self)
    }
}

extension URL {
    func toUrlRequest() -> URLRequest {
        URLRequest(url: self, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
}
