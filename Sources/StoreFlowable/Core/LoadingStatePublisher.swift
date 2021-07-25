//
//  LoadingStatePublisher.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import Combine

/**
 * Type alias of `AnyPublisher<LoadingState<DATA>, Never>`.
 */
public typealias LoadingStatePublisher<DATA> = AnyPublisher<LoadingState<DATA>, Never>
