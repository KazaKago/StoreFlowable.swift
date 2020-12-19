//
//  GithubMetaStateManager.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import StoreFlowable

class GithubMetaStateManager: FlowableDataStateManager<String> {
    static let sharedInstance = GithubMetaStateManager()
}
