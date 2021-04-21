//
//  FlowableState.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import Combine

public typealias FlowableState<DATA> = AnyPublisher<State<DATA>, Never>
