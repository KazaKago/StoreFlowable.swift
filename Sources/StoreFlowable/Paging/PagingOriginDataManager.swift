//
//  PagingOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PagingOriginDataManager {

    associatedtype DATA

    func fetchOrigin(data: [DATA]?, additionalRequest: Bool) -> AnyPublisher<[DATA], Error>
}
