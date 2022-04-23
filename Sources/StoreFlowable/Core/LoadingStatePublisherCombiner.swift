//
//  FlowStateCombiner.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import Combine

public extension Publisher {

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
     func combineState<PUBLISHER_2, RAW_CONTENT_1, RAW_CONTENT_2, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ transform: @escaping (_ content1: RAW_CONTENT_1, _ content2: RAW_CONTENT_2) -> OUTPUT) -> AnyPublisher<LoadingState<OUTPUT>, Self.Failure> where Self.Output == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: Publisher, PUBLISHER_2.Output == LoadingState<RAW_CONTENT_2>, Self.Failure == PUBLISHER_2.Failure {
        combineLatest(statePublisher2) { (state1, state2) in
            state1.zip(state2, transform)
        }
        .eraseToAnyPublisher()
     }

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter statePublisher3: The third `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
    func combineState<PUBLISHER_2, PUBLISHER_3, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3) -> OUTPUT) -> AnyPublisher<LoadingState<OUTPUT>, Self.Failure> where Self.Output == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: Publisher, PUBLISHER_2.Output == LoadingState<RAW_CONTENT_2>, Self.Failure == PUBLISHER_2.Failure, PUBLISHER_3: Publisher, PUBLISHER_3.Output == LoadingState<RAW_CONTENT_3>, Self.Failure == PUBLISHER_3.Failure {
        combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
        .eraseToAnyPublisher()
    }

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter statePublisher3: The third `LoadingStatePublisher` to combine.
     * - parameter statePublisher4: The fourth `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
     func combineState<PUBLISHER_2, PUBLISHER_3, PUBLISHER_4, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4) -> OUTPUT) -> AnyPublisher<LoadingState<OUTPUT>, Self.Failure> where Self.Output == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: Publisher, PUBLISHER_2.Output == LoadingState<RAW_CONTENT_2>, Self.Failure == PUBLISHER_2.Failure, PUBLISHER_3: Publisher, PUBLISHER_3.Output == LoadingState<RAW_CONTENT_3>, Self.Failure == PUBLISHER_3.Failure, PUBLISHER_4: Publisher, PUBLISHER_4.Output == LoadingState<RAW_CONTENT_4>, Self.Failure == PUBLISHER_4.Failure {
         combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .combineState(statePublisher4) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, other)
        }
        .eraseToAnyPublisher()
    }

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter statePublisher3: The third `LoadingStatePublisher` to combine.
     * - parameter statePublisher4: The fourth `LoadingStatePublisher` to combine.
     * - parameter statePublisher5: The fifth `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
    func combineState<PUBLISHER_2, PUBLISHER_3, PUBLISHER_4, PUBLISHER_5, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, RAW_CONTENT_5, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ statePublisher5: PUBLISHER_5, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4, _ rawContent5: RAW_CONTENT_5) -> OUTPUT) -> AnyPublisher<LoadingState<OUTPUT>, Self.Failure> where Self.Output == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: Publisher, PUBLISHER_2.Output == LoadingState<RAW_CONTENT_2>, Self.Failure == PUBLISHER_2.Failure, PUBLISHER_3: Publisher, PUBLISHER_3.Output == LoadingState<RAW_CONTENT_3>, Self.Failure == PUBLISHER_3.Failure, PUBLISHER_4: Publisher, PUBLISHER_4.Output == LoadingState<RAW_CONTENT_4>, Self.Failure == PUBLISHER_4.Failure, PUBLISHER_5: Publisher, PUBLISHER_5.Output == LoadingState<RAW_CONTENT_5>, Self.Failure == PUBLISHER_5.Failure {
        combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .combineState(statePublisher4) { (rawContent, other) in
            (rawContent.0, rawContent.1, rawContent.2, other)
        }
        .combineState(statePublisher5) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, rawContent.3, other)
        }
        .eraseToAnyPublisher()
    }
}
