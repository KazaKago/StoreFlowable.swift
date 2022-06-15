//
//  AdditionalDataState.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

/**
 * Indicates the state of the additional data.
 *
 * This state is only used inside this library.
 */
enum AdditionalDataState {
    case fixed
    case loading
    case error(rawError: Error)
}
