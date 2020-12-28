//
//  GithubApi.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine
import Alamofire

struct GithubApi {

    private let baseApiUrl = URL(string: "https://api.github.com/")!

    func getMeta() -> AnyPublisher<GithubMeta, Error> {
        AF.request(baseApiUrl.appendingPathComponent("meta").toUrlRequest())
            .publishResponse(GithubMeta.self)
            .delay(for: .seconds(1.0), scheduler: RunLoop.main) // dummy delay
            .eraseToAnyPublisher()
    }

    func getOrgs(since: Int?, perPage: Int) -> AnyPublisher<[GithubOrg], Error> {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "per_page", value: String(perPage)))
        if let since = since { queryItems.append(URLQueryItem(name: "since", value: String(since))) }
        var urlComponents = URLComponents(url: baseApiUrl.appendingPathComponent("organizations"), resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        return AF.request((try! urlComponents.asURL()).toUrlRequest())
            .publishResponse([GithubOrg].self)
            .delay(for: .seconds(1.0), scheduler: RunLoop.main) // dummy delay
            .eraseToAnyPublisher()
    }
}

extension URL {
    func toUrlRequest() -> URLRequest {
        URLRequest(url: self, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    }
}
