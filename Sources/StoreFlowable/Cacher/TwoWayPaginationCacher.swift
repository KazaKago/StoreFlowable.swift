//
//  TwoWayPaginationCacher.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/10.
//

import Foundation

/**
 * A Cacher class that supports pagination in two direction.
 * Override the get / set methods as needed.
 *
 * @see com.kazakago.storeflowable.from
 */
open class TwoWayPaginationCacher<PARAM: Hashable, DATA>: PaginationCacher<PARAM, DATA> {

    private var prevRequestKeyMap: [PARAM: String] = [:]

    /**
     * The previous data saving process to cache.
     * You need to merge cached data & new fetched previous data.
     *
     * @param cachedData Currently cached data.
     * @param newData Data to be saved.
     */
    open func savePrevData(cachedData: [DATA], newData: [DATA], param: PARAM) async {
        await saveData(data: newData + cachedData, param: param)
    }

    /**
     * Get RequestKey to Fetch the prev pagination data.
     *
     * @param param Key to get the specified data.
     */
    open func loadPrevRequestKey(param: PARAM) async -> String? {
        prevRequestKeyMap[param]
    }

    /**
     * Save RequestKey to Fetch the prev pagination data.
     *
     * @param requestKey pagination request key.
     * @param param Key to get the specified data.
     */
    open func savePrevRequestKey(requestKey: String?, param: PARAM) async {
        prevRequestKeyMap[param] = requestKey
    }
}
