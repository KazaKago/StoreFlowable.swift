//
//  AdditionalDataState.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

enum AdditionalDataState {
    case fixed
    case loading
    case error(rawError: Error)
}
