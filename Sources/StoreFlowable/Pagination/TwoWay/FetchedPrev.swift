//
//  FetchedPrev.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

/**
 * Result of previous fetching from origin.
 *
 * - DATA: Specify the type of data to be handled.
 */
public struct FetchedPrev<DATA> {
    /**
     * Set the acquired raw data.
     */
    let data: DATA
    /**
     * Set the key to fetch the previous data. For example, "Previous page number" and "Previous page token", etc...
     * If `nil` or `empty` is set, it is considered that there is no previous page.
     */
    let prevKey: String?

    public init (data: DATA, prevKey: String?) {
        self.data = data
        self.prevKey = prevKey
    }
}
