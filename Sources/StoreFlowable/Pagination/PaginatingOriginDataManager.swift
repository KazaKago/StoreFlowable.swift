//
//  PaginatingOriginDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

public protocol PaginatingOriginDataManager: OriginDataManager {

    func fetchAdditionalDataFromOrigin(cachedData: DATA?) -> AnyPublisher<FetchingResult<DATA>, Error>
}
