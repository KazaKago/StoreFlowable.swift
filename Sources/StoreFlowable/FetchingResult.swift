//
//  FetchingResult.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

import Foundation
import Combine

public struct FetchingResult<DATA> {
    let data: DATA
    let noMoreAdditionalData: Bool

    public init(data: DATA, noMoreAdditionalData: Bool = false) {
        self.data = data
        self.noMoreAdditionalData = noMoreAdditionalData
    }
}
