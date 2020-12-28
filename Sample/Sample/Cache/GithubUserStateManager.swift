//
//  GithubUserStateManager.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import StoreFlowable

class GithubUserStateManager: FlowableDataStateManager<String> {
    static let shared = GithubUserStateManager()
}
