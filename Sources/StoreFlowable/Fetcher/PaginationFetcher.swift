//
//  PaginationFetcher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

import Foundation

/**
 * A Fetcher class that supports pagination in one direction.
 *
 * @see com.kazakago.storeflowable.from
 */
public protocol PaginationFetcher {

    associatedtype PARAM: Hashable
    associatedtype DATA

    typealias Fetched = PaginationFetcherResult

    /**
     * The latest data acquisition process from origin.
     *
     * @return [Result] class including the acquired data.
     */
    func fetch(param: PARAM) async throws -> Fetched<DATA>

    /**
     * The latest data acquisition process from origin.
     *
     * @return [Result] class including the acquired data.
     */
    func fetchNext(nextKey: String, param: PARAM) async throws -> Fetched<DATA>
}

/**
 * Result of Fetching from origin.
 *
 * @param DATA Specify the type of data to be handled.
 */
public struct PaginationFetcherResult<DATA> {
    /**
     * Set the acquired raw data.
     */
    let data: [DATA]
    /**
     * Set the key to fetch the next data. For example, "Next page number" and "Next page token", etc...
     * If `null` or `empty` is set, it is considered that there is no next page.
     */
    let nextRequestKey: String?

    public init(data: [DATA], nextRequestKey: String?) {
        self.data = data
        self.nextRequestKey = nextRequestKey
    }
}
