//
//  FlowStateCombiner.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation
import AsyncExtensions

public extension AsyncSequence {

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
    func combineState<PUBLISHER_2, RAW_CONTENT_1, RAW_CONTENT_2, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ transform: @escaping (_ content1: RAW_CONTENT_1, _ content2: RAW_CONTENT_2) -> OUTPUT) -> AnyAsyncSequence<LoadingState<OUTPUT>> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: AsyncSequence, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2> {
        let ziped = AsyncSequences.Zip2(self, statePublisher2)
        return ziped.map { (state1, state2) in
            state1.zip(state2, transform)
        }.eraseToAnyAsyncSequence()
     }

    /**
     * Combine multiple `LoadingStatePublisher`.
     *
     * - parameter statePublisher2: The second `LoadingStatePublisher` to combine.
     * - parameter statePublisher3: The third `LoadingStatePublisher` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStatePublisher` containing the combined data.
     */
    func combineState<PUBLISHER_2, PUBLISHER_3, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3) -> OUTPUT) -> AnyAsyncSequence<LoadingState<OUTPUT>> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: AsyncSequence, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3: AsyncSequence, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3> {
        combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
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
     func combineState<PUBLISHER_2, PUBLISHER_3, PUBLISHER_4, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4) -> OUTPUT) -> AnyAsyncSequence<LoadingState<OUTPUT>> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: AsyncSequence, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3: AsyncSequence, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3>, PUBLISHER_4: AsyncSequence, PUBLISHER_4.Element == LoadingState<RAW_CONTENT_4> {
         combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            (rawContent.0, rawContent.1, other)
        }
        .combineState(statePublisher4) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, rawContent.2, other)
        }
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
    func combineState<PUBLISHER_2, PUBLISHER_3, PUBLISHER_4, PUBLISHER_5, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, RAW_CONTENT_5, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ statePublisher5: PUBLISHER_5, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4, _ rawContent5: RAW_CONTENT_5) -> OUTPUT) -> AnyAsyncSequence<LoadingState<OUTPUT>> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2: AsyncSequence, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3: AsyncSequence, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3>, PUBLISHER_4: AsyncSequence, PUBLISHER_4.Element == LoadingState<RAW_CONTENT_4>, PUBLISHER_5: AsyncSequence, PUBLISHER_5.Element == LoadingState<RAW_CONTENT_5> {
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
    }
}
