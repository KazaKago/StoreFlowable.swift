//
//  GithubInMemoryCache.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation

struct GithubInMemoryCache {
    static var metaCache: GithubMeta?
    static var metaCacheCreatedAt: Date?

    static var orgsCache: [GithubOrg]?
    static var orgsCacheCreatedAt: Date?
}
