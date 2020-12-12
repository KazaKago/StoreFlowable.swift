//
//  DataState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

public enum DataState {
    case fixed(isReachLast: Bool = false)
    case loading
    case error(error: Error)
}
