//
//  PaginationCacher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

import Foundation

/**
 * A Cacher class that supports pagination in one direction.
 * Override the get / set methods as needed.
 *
 * @see com.kazakago.storeflowable.from
 */
public class PaginationCacher<PARAM: Hashable, DATA>: Cacher<PARAM, [DATA]> {

    private var nextRequestKeyMap: [PARAM: String] = [:]

    /**
     * The next data saving process to cache.
     * You need to merge cached data & new fetched next data.
     *
     * @param cachedData Currently cached data.
     * @param newData Data to be saved.
     * @param param Key to get the specified data.
     */
    public func saveNextData(cachedData: [DATA], newData: [DATA], param: PARAM) async {
        await saveData(data: cachedData + newData, param: param)
    }

    /**
     * Get RequestKey to Fetch the next pagination data.
     *
     * @param param Key to get the specified data.
     */
    public func loadNextRequestKey(param: PARAM) async -> String? {
        nextRequestKeyMap[param]
    }

    /**
     * Save RequestKey to Fetch the next pagination data.
     *
     * @param requestKey pagination request key.
     * @param param Key to get the specified data.
     */
    public func saveNextRequestKey(requestKey: String?, param: PARAM) async {
        nextRequestKeyMap[param] = requestKey
    }
}
