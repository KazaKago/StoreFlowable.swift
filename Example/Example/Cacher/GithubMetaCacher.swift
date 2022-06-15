//
//  GithubMetaCacher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import StoreFlowable

class GithubMetaCacher: Cacher<UnitHash, GithubMeta> {

    static let shared = GithubMetaCacher()

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60 * 30) }
    }

    override private init() {
    }
}
