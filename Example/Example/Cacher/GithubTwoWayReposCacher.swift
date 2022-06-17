//
//  GithubTwoWayReposCacher.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

class GithubTwoWayReposCacher: TwoWayPaginationCacher<String, GithubRepo> {

    static let shared = GithubTwoWayReposCacher()

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60) }
    }

    override private init() {
    }
}
