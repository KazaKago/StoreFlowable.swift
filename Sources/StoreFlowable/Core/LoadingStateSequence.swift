//
//  LoadingStateSequence.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import AsyncExtensions

/**
 * Type alias of `AnyPublisher<LoadingState<DATA>, Never>`.
 */
public typealias LoadingStateSequence<DATA> = AnyAsyncSequence<LoadingState<DATA>>
