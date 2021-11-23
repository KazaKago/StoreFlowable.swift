//
//  FlowAccessor.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

protocol FlowAccessor {

    associatedtype PARAM

    func getFlow(param: PARAM) -> AnyPublisher<DataState, Never>
}
