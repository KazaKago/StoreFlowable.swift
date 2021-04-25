//
//  OriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

/**
 * Provides functions related to data input / output from origin.
 */
public protocol OriginDataManager {

    /**
     * Specify the type of data to be handled.
     */
    associatedtype DATA

    /**
     * The latest data acquisition process from origin.
     *
     * - returns: `FetchingResult` class including the acquired data.
     */
    func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<DATA>, Error>
}
