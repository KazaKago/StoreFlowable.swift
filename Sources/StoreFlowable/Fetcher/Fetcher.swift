//
//  Fetcher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

/**
 * Class for fetching origin data from server.
 *
 * @see com.kazakago.storeflowable.from
 */
public protocol Fetcher {

    associatedtype PARAM: Hashable
    associatedtype DATA

    /**
     * The latest data acquisition process from origin.
     *
     * @return acquired data.
     */
    func fetch(param: PARAM) async throws -> DATA
}
