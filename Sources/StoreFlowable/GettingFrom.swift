//
//  GettingFrom.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

/**
 * This enum to specify where to get data when getting data.
 */
public enum GettingFrom {
    /**
     * Use both origin and cache.
     * Returns a valid cache if it exists, otherwise try to get it from origin.
     */
    case both
    /**
     * Always try to get data from origin.
     */
    case origin
    /**
     * Always try to get data from cache.
     */
    case cache
    /**
     * Use `both`,
     */
    @available(*, deprecated, renamed: "both")
    case mix
    /**
     * Use `origin`,
     */
    @available(*, deprecated, renamed: "origin")
    case fromOrigin
    /**
     * Use `cache`,
     */
    @available(*, deprecated, renamed: "cache")
    case fromCache
}
