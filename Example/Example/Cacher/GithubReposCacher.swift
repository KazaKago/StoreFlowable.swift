//
//  GithubReposCacher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import StoreFlowable

class GithubReposCacher: PaginationCacher<String, GithubRepo> {

    static let shared = GithubReposCacher()

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60) }
    }

    override private init() {
    }
}
