//
//  PublisherExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/19.
//

import Foundation
import Combine

extension Publisher {
    func ignoreError() -> AnyPublisher<Output, Never> {
        Future<Output, Never> { promise in
            _ = self.sink { error in
                // do nothing.
            } receiveValue: { output in
                promise(.success(output))
            }
        }.eraseToAnyPublisher()
    }
}
