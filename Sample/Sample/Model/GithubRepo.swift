//
//  GithubRepo.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation

struct GithubRepo: Codable, Equatable, Identifiable {
    let id: Int
    let fullName: String
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullName = "full_name"
        case htmlUrl = "html_url"
   }
}
