//
//  KeyedRequestType.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

enum KeyedRequestType {
    case refresh
    case next(requestKey: String)
    case prev(requestKey: String)
}
