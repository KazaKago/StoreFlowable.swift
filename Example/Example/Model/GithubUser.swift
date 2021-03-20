//
//  GithubUser.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

struct GithubUser: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let htmlUrl: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case htmlUrl = "html_url"
        case avatarUrl = "avatar_url"
   }
}
