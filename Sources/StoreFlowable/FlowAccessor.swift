//
//  FlowAccessor.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

protocol FlowAccessor {

    associatedtype KEY

    func getFlow(key: KEY) -> AnyPublisher<DataState, Error>
}
