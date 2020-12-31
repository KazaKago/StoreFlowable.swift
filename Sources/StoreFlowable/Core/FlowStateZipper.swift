//
//  FlowStateCombiner.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    func zipState<A, B, Z>(_ otherPublisher: AnyPublisher<State<B>, Self.Failure>, _ transform: @escaping (_ content1: A, _ content2: B) -> Z) -> AnyPublisher<State<Z>, Self.Failure> where Self.Output == State<A> {
        zip(otherPublisher) { (state1, state2) in
            state1.zip(state2, transform)
        }
        .eraseToAnyPublisher()
    }

    func zipState<A, B, C, Z>(_ otherPublisher1: AnyPublisher<State<B>, Self.Failure>, _ otherPublisher2: AnyPublisher<State<C>, Self.Failure>, _ transform: @escaping (_ content1: A, _ content2: B, _ content3: C) -> Z) -> AnyPublisher<State<Z>, Self.Failure> where Self.Output == State<A> {
        zipState(otherPublisher1) { (state1, state2) in
            (state1, state2)
        }
        .zipState(otherPublisher2) { (state1_2, state3) in
            transform(state1_2.0, state1_2.1, state3)
        }
        .eraseToAnyPublisher()
    }

    func zipState<A, B, C, D, Z>(_ otherPublisher1: AnyPublisher<State<B>, Self.Failure>, _ otherPublisher2: AnyPublisher<State<C>, Self.Failure>, _ otherPublisher3: AnyPublisher<State<D>, Self.Failure>, _ transform: @escaping (_ content1: A, _ content2: B, _ content3: C, _ content4: D) -> Z) -> AnyPublisher<State<Z>, Self.Failure> where Self.Output == State<A> {
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

    func zipState<A, B, C, D, E, Z>(_ otherPublisher1: AnyPublisher<State<B>, Self.Failure>, _ otherPublisher2: AnyPublisher<State<C>, Self.Failure>, _ otherPublisher3: AnyPublisher<State<D>, Self.Failure>, _ otherPublisher4: AnyPublisher<State<E>, Self.Failure>, _ transform: @escaping (_ content1: A, _ content2: B, _ content3: C, _ content4: D, _ content5: E) -> Z) -> AnyPublisher<State<Z>, Self.Failure> where Self.Output == State<A> {
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
