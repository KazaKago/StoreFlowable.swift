//
//  FlowStateCombiner.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import AsyncExtensions

public extension AsyncSequence {

    /**
     * Combine multiple `LoadingStateSequence`.
     *
     * - parameter statePublisher2: The second `LoadingStateSequence` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStateSequence` containing the combined data.
     */
    func combineState<PUBLISHER_2: AsyncSequence, RAW_CONTENT_1, RAW_CONTENT_2, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ transform: @escaping (_ content1: RAW_CONTENT_1, _ content2: RAW_CONTENT_2) -> OUTPUT) -> LoadingStateSequence<OUTPUT> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2> {
        flatMapLatest { state1 in
            statePublisher2.map { state2 in
                state1.zip(state2, transform)
            }
        }.eraseToLoadingStateSequence()
     }

    /**
     * Combine multiple `LoadingStateSequence`.
     *
     * - parameter statePublisher2: The second `LoadingStateSequence` to combine.
     * - parameter statePublisher3: The third `LoadingStateSequence` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStateSequence` containing the combined data.
     */
    func combineState<PUBLISHER_2: AsyncSequence, PUBLISHER_3: AsyncSequence, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3) -> OUTPUT) -> LoadingStateSequence<OUTPUT> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3> {
        combineState(statePublisher2) { (rawContent, other) in
            (rawContent, other)
        }
        .combineState(statePublisher3) { (rawContent, other) in
            transform(rawContent.0, rawContent.1, other)
        }
    }

    /**
     * Combine multiple `LoadingStateSequence`.
     *
     * - parameter statePublisher2: The second `LoadingStateSequence` to combine.
     * - parameter statePublisher3: The third `LoadingStateSequence` to combine.
     * - parameter statePublisher4: The fourth `LoadingStateSequence` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStateSequence` containing the combined data.
     */
    func combineState<PUBLISHER_2: AsyncSequence, PUBLISHER_3: AsyncSequence, PUBLISHER_4: AsyncSequence, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4) -> OUTPUT) -> LoadingStateSequence<OUTPUT> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3>, PUBLISHER_4.Element == LoadingState<RAW_CONTENT_4> {
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
     * Combine multiple `LoadingStateSequence`.
     *
     * - parameter statePublisher2: The second `LoadingStateSequence` to combine.
     * - parameter statePublisher3: The third `LoadingStateSequence` to combine.
     * - parameter statePublisher4: The fourth `LoadingStateSequence` to combine.
     * - parameter statePublisher5: The fifth `LoadingStateSequence` to combine.
     * - parameter transform: This callback that returns the result of combining the data.
     * - returns: Return `LoadingStateSequence` containing the combined data.
     */
    func combineState<PUBLISHER_2: AsyncSequence, PUBLISHER_3: AsyncSequence, PUBLISHER_4: AsyncSequence, PUBLISHER_5: AsyncSequence, RAW_CONTENT_1, RAW_CONTENT_2, RAW_CONTENT_3, RAW_CONTENT_4, RAW_CONTENT_5, OUTPUT>(_ statePublisher2: PUBLISHER_2, _ statePublisher3: PUBLISHER_3, _ statePublisher4: PUBLISHER_4, _ statePublisher5: PUBLISHER_5, _ transform: @escaping (_ rawContent1: RAW_CONTENT_1, _ rawContent2: RAW_CONTENT_2, _ rawContent3: RAW_CONTENT_3, _ rawContent4: RAW_CONTENT_4, _ rawContent5: RAW_CONTENT_5) -> OUTPUT) -> LoadingStateSequence<OUTPUT> where Self.Element == LoadingState<RAW_CONTENT_1>, PUBLISHER_2.Element == LoadingState<RAW_CONTENT_2>, PUBLISHER_3.Element == LoadingState<RAW_CONTENT_3>, PUBLISHER_4.Element == LoadingState<RAW_CONTENT_4>, PUBLISHER_5.Element == LoadingState<RAW_CONTENT_5> {
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
