//
//  StatePublisher.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import Combine

/**
 * Type alias of `AnyPublisher<State<DATA>, Never>`.
 */
public typealias StatePublisher<DATA> = AnyPublisher<State<DATA>, Never>
