//
//  FetchingResult.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import Combine

/**
 * Result of Fetching from origin.
 *
 * - DATA: Specify the type of data to be handled.
 */
public struct FetchingResult<DATA> {
    /**
     * Set the acquired raw data.
     */
    let data: DATA
    /**
     * Set to `true` if you know at Pagination that there is no more additional data.
     *
     * Has no effect without Pagination.
     */
    let noMoreAdditionalData: Bool

    public init(data: DATA, noMoreAdditionalData: Bool = false) {
        self.data = data
        self.noMoreAdditionalData = noMoreAdditionalData
    }
}
