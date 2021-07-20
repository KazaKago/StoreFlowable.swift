//
//  FetchedInitial.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

/**
 * Result of initial fetching from origin.
 *
 * - DATA: Specify the type of data to be handled.
 */
public struct FetchedInitial<DATA> {
    /**
     * Set the acquired raw data.
     */
    let data: DATA
    /**
     * Set the key to fetch the next data. For example, "Next page number" and "Next page token", etc...
     * If `nil` or `empty` is set, it is considered that there is no next page.
     */
    let nextKey: String?
    /**
     * Set the key to fetch the previous data. For example, "Previous page number" and "Previous page token", etc...
     * If `nil` or `empty` is set, it is considered that there is no previous page.
     */
    let prevKey: String?
    
    public init (data: DATA, nextKey: String?, prevKey: String?) {
        self.data = data
        self.nextKey = nextKey
        self.prevKey = prevKey
    }
}
