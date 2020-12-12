//
//  StoreFlowable.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation
import Combine

protocol StoreFlowable {

    associatedtype KEY: Hashable
    associatedtype DATA

    func asFlow() -> AnyPublisher<State<DATA>, Error>

    func asFlow(forceRefresh: Bool) -> AnyPublisher<State<DATA>, Error>

    func get() -> AnyPublisher<DATA, Error>

    func get(type: AsDataType) -> AnyPublisher<DATA, Error>

    func validate() -> AnyPublisher<Void, Error>

    func request() -> AnyPublisher<Void, Error>

    func update(newData: DATA?) -> AnyPublisher<Void, Error>
}
