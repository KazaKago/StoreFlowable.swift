//
//  GithubReposStateManager.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import StoreFlowable

class GithubReposStateManager: FlowableDataStateManager<String> {

    static let shared = GithubReposStateManager()

    private override init() {
    }
}
