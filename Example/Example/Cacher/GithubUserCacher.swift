//
//  GithubUserCacher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import StoreFlowable

class GithubUserCacher: Cacher<String, GithubUser> {

    static let shared = GithubUserCacher()

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60 * 30) }
    }

    override private init() {
    }
}
