//
//  GithubTwoWayReposStateManager.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import StoreFlowable

class GithubTwoWayReposStateManager: FlowableDataStateManager<String> {

    static let shared = GithubTwoWayReposStateManager()

    private override init() {
    }
}
