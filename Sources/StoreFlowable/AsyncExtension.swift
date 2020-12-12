//
//  AsyncExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/07.
//

import Foundation
import Combine
import CombineAsync

func async<T>(_ body: @escaping () throws -> T) -> Async<T> {
    async { yield in
        yield(try body())
    }
}
