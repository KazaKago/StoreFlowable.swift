//
//  GithubOrg.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation

struct GithubOrg: Codable, Equatable, Identifiable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "login"
   }
}
