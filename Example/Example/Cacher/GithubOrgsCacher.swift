//
//  GithubOrgsCacher.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import StoreFlowable

class GithubOrgsCacher: PaginationCacher<UnitHash, GithubOrg> {

    static let shared = GithubOrgsCacher()

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60 * 30) }
    }

    override private init() {
    }
}
