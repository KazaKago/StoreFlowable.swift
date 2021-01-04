//
//  FlowStateCombiner.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    func zipState<OTHER_1, RAW_SELF, RAW_1, OUTPUT>(_ otherPublisher: OTHER_1, _ transform: @escaping (_ content1: RAW_SELF, _ content2: RAW_1) -> OUTPUT) -> AnyPublisher<State<OUTPUT>, Self.Failure> where Self.Output == State<RAW_SELF>, OTHER_1 : Publisher, OTHER_1.Output == State<RAW_1>, Self.Failure == OTHER_1.Failure {
        zip(otherPublisher) { (state1, state2) in
            state1.zip(state2, transform)
        }
        .eraseToAnyPublisher()
    }

    func zipState<OTHER_1, OTHER_2, RAW_SELF, RAW_1, RAW_2, OUTPUT>(_ otherPublisher1: OTHER_1, _ otherPublisher2: OTHER_2, _ transform: @escaping (_ content1: RAW_SELF, _ content2: RAW_1, _ content3: RAW_2) -> OUTPUT) -> AnyPublisher<State<OUTPUT>, Self.Failure> where Self.Output == State<RAW_SELF>, OTHER_1 : Publisher, OTHER_1.Output == State<RAW_1>, Self.Failure == OTHER_1.Failure, OTHER_2 : Publisher, OTHER_2.Output == State<RAW_2>, Self.Failure == OTHER_2.Failure {
        zipState(otherPublisher1) { (state1, state2) in
            (state1, state2)
        }
        .zipState(otherPublisher2) { (state1_2, state3) in
            transform(state1_2.0, state1_2.1, state3)
        }
        .eraseToAnyPublisher()
    }

    func zipState<OTHER_1, OTHER_2, OTHER_3, RAW_SELF, RAW_1, RAW_2, RAW_3, OUTPUT>(_ otherPublisher1: OTHER_1, _ otherPublisher2: OTHER_2, _ otherPublisher3: OTHER_3, _ transform: @escaping (_ content1: RAW_SELF, _ content2: RAW_1, _ content3: RAW_2, _ content4: RAW_3) -> OUTPUT) -> AnyPublisher<State<OUTPUT>, Self.Failure> where Self.Output == State<RAW_SELF>, OTHER_1 : Publisher, OTHER_1.Output == State<RAW_1>, Self.Failure == OTHER_1.Failure, OTHER_2 : Publisher, OTHER_2.Output == State<RAW_2>, Self.Failure == OTHER_2.Failure, OTHER_3 : Publisher, OTHER_3.Output == State<RAW_3>, Self.Failure == OTHER_3.Failure {
        zipState(otherPublisher1) { (state1, state2) in
            (state1, state2)
        }
        .zipState(otherPublisher2) { (state1_2, state3) in
            (state1_2.0, state1_2.1, state3)
        }
        .zipState(otherPublisher3) { (state1_2_3, state4) in
            transform(state1_2_3.0, state1_2_3.1, state1_2_3.2, state4)
        }
        .eraseToAnyPublisher()
    }

    func zipState<OTHER_1, OTHER_2, OTHER_3, OTHER_4, RAW_SELF, RAW_1, RAW_2, RAW_3, RAW_4, OUTPUT>(_ otherPublisher1: OTHER_1, _ otherPublisher2: OTHER_2, _ otherPublisher3: OTHER_3, _ otherPublisher4: OTHER_4, _ transform: @escaping (_ content1: RAW_SELF, _ content2: RAW_1, _ content3: RAW_2, _ content4: RAW_3, _ content5: RAW_4) -> OUTPUT) -> AnyPublisher<State<OUTPUT>, Self.Failure> where Self.Output == State<RAW_SELF>, OTHER_1 : Publisher, OTHER_1.Output == State<RAW_1>, Self.Failure == OTHER_1.Failure, OTHER_2 : Publisher, OTHER_2.Output == State<RAW_2>, Self.Failure == OTHER_2.Failure, OTHER_3 : Publisher, OTHER_3.Output == State<RAW_3>, Self.Failure == OTHER_3.Failure, OTHER_4 : Publisher, OTHER_4.Output == State<RAW_4>, Self.Failure == OTHER_4.Failure {
        zipState(otherPublisher1) { (state1, state2) in
            (state1, state2)
        }
        .zipState(otherPublisher2) { (state1_2, state3) in
            (state1_2.0, state1_2.1, state3)
        }
        .zipState(otherPublisher3) { (state1_2_3, state4) in
            (state1_2_3.0, state1_2_3.1, state1_2_3.2, state4)
        }
        .zipState(otherPublisher4) { (state1_2_3_4, state5) in
            transform(state1_2_3_4.0, state1_2_3_4.1, state1_2_3_4.2, state1_2_3_4.3, state5)
        }
        .eraseToAnyPublisher()
    }
}
