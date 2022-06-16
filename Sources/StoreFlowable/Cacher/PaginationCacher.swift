//
//  PaginationCacher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

/**
 * A Cacher class that supports pagination in one direction.
 * Override the get / set methods as needed.
 *
 * @see com.kazakago.storeflowable.from
 */
open class PaginationCacher<PARAM: Hashable, DATA>: Cacher<PARAM, [DATA]> {

    private var nextRequestKeyMap: [PARAM: String] = [:]

    /**
     * The next data saving process to cache.
     * You need to merge cached data & new fetched next data.
     *
     * - parameter cachedData: Currently cached data.
     * - parameter newData: Data to be saved.
     * - parameter param: Key to get the specified data.
     */
    open func saveNextData(cachedData: [DATA], newData: [DATA], param: PARAM) async {
        await saveData(data: cachedData + newData, param: param)
    }

    /**
     * Get RequestKey to Fetch the next pagination data.
     *
     * - parameter param: Key to get the specified data.
     * - returns: Next request key.
     */
    open func loadNextRequestKey(param: PARAM) async -> String? {
        nextRequestKeyMap[param]
    }

    /**
     * Save RequestKey to Fetch the next pagination data.
     *
     * - parameter requestKey: pagination request key.
     * - parameter param: Key to get the specified data.
     */
    open func saveNextRequestKey(requestKey: String?, param: PARAM) async {
        nextRequestKeyMap[param] = requestKey
    }
}
