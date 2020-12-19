//
//  OriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine

public protocol OriginDataManager {

    associatedtype DATA

    func fetchOrigin() -> AnyPublisher<DATA, Error>
}
