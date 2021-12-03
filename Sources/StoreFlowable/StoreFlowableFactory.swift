//
//  StoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/10.
//

import Foundation
import Combine

/**
 * Abstract factory class for `StoreFlowable` class.
 *
 * Create a class that implements origin or cache data Input / Output according to this interface.
 */
public protocol StoreFlowableFactory: BaseStoreFlowableFactory {

    /**
     * The latest data acquisition process from origin.
     *
     * - returns acquired data.
     */
    func fetchDataFromOrigin(param: PARAM) -> AnyPublisher<DATA, Error>
}
