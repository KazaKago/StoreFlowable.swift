//
//  GettingFrom.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

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
}
