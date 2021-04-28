//
//  DataState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

/**
 * Indicates the state of the data.
 *
 * This state is only used inside the `StoreFlowable`.
 */
public enum DataState {
    /**
     * No processing state.
     *
     * - noMoreAdditionalData: Set to `true` if you know at Pagination that there is no more additional data. Has no effect without Pagination.
     */
    case fixed(noMoreAdditionalData: Bool = false)
    /**
     * Acquiring data state.
     */
    case loading
    /**
     * An error when processing state.
     *
     * - rawError: The entity of the exception that occurred.
     */
    case error(rawError: Error)
}
