//
//  AdditionalDataState.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

import Foundation

/**
 * Indicates the state of the additional data.
 *
 * This state is only used inside this library.
 */
public enum AdditionalDataState {
    case fixed(additionalRequestKey: String)
    case fixedWithNoMoreAdditionalData
    case loading(additionalRequestKey: String)
    case error(additionalRequestKey: String, rawError: Error)

    func additionalRequestKeyOrNil() -> String? {
        switch (self) {
        case .fixed(let additionalRequestKey):
            return additionalRequestKey
        case .fixedWithNoMoreAdditionalData:
            return nil
        case .loading(let additionalRequestKey):
            return additionalRequestKey
        case .error(let additionalRequestKey, _):
            return additionalRequestKey
        }
    }
}
