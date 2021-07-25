//
//  Fetched.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation

/**
 * Result of Fetching from origin.
 *
 * - DATA: Specify the type of data to be handled.
 */
public struct Fetched<DATA> {
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
