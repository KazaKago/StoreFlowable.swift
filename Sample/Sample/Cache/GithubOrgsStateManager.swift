//
//  GithubOrgsStateManager.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/25.
//

import Foundation
import StoreFlowable

class GithubOrgsStateManager: FlowableDataStateManager<UnitHash> {
    static let shared = GithubOrgsStateManager()
}
