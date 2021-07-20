//
//  FetchedNext.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

/**
 * Result of next fetching from origin.
 *
 * - DATA: Specify the type of data to be handled.
 */
public struct FetchedNext<DATA> {
    /**
     * Set the acquired raw data.
     */
    let data: DATA
    /**
     * Set the key to fetch the next data. For example, "Next page number" and "Next page token", etc...
     * If `nil` or `empty` is set, it is considered that there is no next page.
     */
    let nextKey: String?

    public init (data: DATA, nextKey: String?) {
        self.data = data
        self.nextKey = nextKey
    }
}
