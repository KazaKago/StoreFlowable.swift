//
//  TwoWayPaginationFetcher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

import Foundation

/**
 * A Fetcher class that supports pagination in two direction.
 *
 * @see com.kazakago.storeflowable.from
 */
public protocol TwoWayPaginationFetcher {

    associatedtype PARAM: Hashable
    associatedtype DATA

    typealias Result = TwoWayPaginationFetcherResult

    /**
     * The latest data acquisition process from origin.
     *
     * @return [Result] class including the acquired data.
     */
    func fetch(param: PARAM) async throws -> Result.Initial<DATA>

    /**
     * Next data acquisition process from origin.
     *
     * @param nextKey Key for next data request.
     * @return [Result] class including the acquired data.
     */
    func fetchNext(nextKey: String, param: PARAM) async throws -> Result.Next<DATA>

    /**
     * Previous data acquisition process from origin.
     *
     * @param prevKey Key for previous data request.
     * @return [Fetched] class including the acquired data.
     */
    func fetchPrev(prevKey: String, param: PARAM) async throws -> Result.Prev<DATA>
}

/**
 * Result of Fetching from origin.
 *
 * @param DATA Specify the type of data to be handled.
 */
public protocol TwoWayPaginationFetcherResult {

    associatedtype DATA

    /**
     * Set the acquired raw data.
     */
    var data: [DATA] { get }

    typealias Initial = TwoWayPaginationFetcherResultInitial
    typealias Next = TwoWayPaginationFetcherResultNext
    typealias Prev = TwoWayPaginationFetcherResultPrev
}

/**
 * Result of initial fetching from origin.
 *
 * @param DATA Specify the type of data to be handled.
 */
public struct TwoWayPaginationFetcherResultInitial<DATA>: TwoWayPaginationFetcherResult {

    public typealias DATA = DATA

    public let data: [DATA]

    /**
     * Set the key to fetch the next data. For example, "Next page number" and "Next page token", etc...
     * If `null` or `empty` is set, it is considered that there is no next page.
     */
    let nextRequestKey: String?
    /**
     * Set the key to fetch the previous data. For example, "Prev page number" and "Prev page token", etc...
     * If `null` or `empty` is set, it is considered that there is no previous page.
     */
    let prevRequestKey: String?
}

/**
 * Result of next fetching from origin.
 *
 * @param DATA Specify the type of data to be handled.
 */
public struct TwoWayPaginationFetcherResultNext<DATA>: TwoWayPaginationFetcherResult {

    public typealias DATA = DATA

    public let data: [DATA]

    /**
     * Set the key to fetch the next data. For example, "Next page number" and "Next page token", etc...
     * If `null` or `empty` is set, it is considered that there is no next page.
     */
    let nextRequestKey: String?
}

/**
 * Result of previous fetching from origin.
 *
 * @param DATA Specify the type of data to be handled.
 */
public struct TwoWayPaginationFetcherResultPrev<DATA>: TwoWayPaginationFetcherResult {

    public typealias DATA = DATA

    public let data: [DATA]

    /**
     * Set the key to fetch the previous data. For example, "Prev page number" and "Prev page token", etc...
     * If `null` or `empty` is set, it is considered that there is no previous page.
     */
    let prevRequestKey: String?
}
