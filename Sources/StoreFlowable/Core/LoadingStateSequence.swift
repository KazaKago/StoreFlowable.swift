//
//  LoadingStateSequence.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2021/04/18.
//

extension AsyncSequence {
    func eraseToLoadingStateSequence<DATA>() -> LoadingStateSequence<DATA> where Element == LoadingState<DATA> {
        LoadingStateSequence(self)
    }
}

/**
 * AsyncSequence with LoadingState<DATA>
 */
public struct LoadingStateSequence<DATA>: AsyncSequence {
    public typealias Element = LoadingState<DATA>
    public typealias AsyncIterator = Iterator

    private let makeAsyncIteratorClosure: () -> AsyncIterator

    public init<BaseAsyncSequence: AsyncSequence>(_ baseAsyncSequence: BaseAsyncSequence) where BaseAsyncSequence.Element == Element {
        self.makeAsyncIteratorClosure = { Iterator(baseIterator: baseAsyncSequence.makeAsyncIterator()) }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        Iterator(baseIterator: self.makeAsyncIteratorClosure())
    }

    public struct Iterator: AsyncIteratorProtocol {
        private let nextClosure: () async -> Element?

        public init<BaseAsyncIterator: AsyncIteratorProtocol>(baseIterator: BaseAsyncIterator) where BaseAsyncIterator.Element == Element {
            var baseIterator = baseIterator
            self.nextClosure = { try! await baseIterator.next() }
        }

        public func next() async -> Element? {
            await self.nextClosure()
        }
    }
}
