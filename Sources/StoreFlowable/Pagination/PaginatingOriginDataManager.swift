//
//  PaginatingOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

/**
 * Provides functions related to data input / output from origin.
 */
public protocol PaginatingOriginDataManager: OriginDataManager {

    /**
     * The additional data acquisition process from origin.
     *
     * Get from origin considering pagination when implementing this method.
     *
     * - parameter cachedData: existing cache data.
     * - returns: `FetchingResult` class including the acquired data
     */
    func fetchAdditionalDataFromOrigin(cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error>
}
