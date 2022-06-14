import XCTest
@testable import StoreFlowable

final class LoadingStateSequenceCombinerTests: XCTestCase {

    private let loadingPublisher = AsyncStream<LoadingState<Int>> { continuation in
        continuation.yield(.loading(content: nil))
        continuation.finish()
    }
    private let loadingPublisherWithData = AsyncStream<LoadingState<Int>> { continuation in
        continuation.yield(.loading(content: 70))
        continuation.finish()
    }
    private let completedPublisher = AsyncStream<LoadingState<Int>> { continuation in
        continuation.yield(.completed(content: 30, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true)))
        continuation.finish()
    }
    private let errorPublisher = AsyncStream<LoadingState<Int>> { continuation in
        continuation.yield(.error(rawError: NoSuchElementError()))
        continuation.finish()
    }

    func test_Combine_Loading_Loading() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisher.combineState(loadingPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, nil)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Loading_LoadingWithData() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisher.combineState(loadingPublisherWithData) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, nil)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Loading_Completed() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisher.combineState(completedPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, nil)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Loading_Error() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisher.combineState(errorPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_LoadingWithData_Loading() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisherWithData.combineState(loadingPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, nil)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_LoadingWithData_LoadingWithData() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisherWithData.combineState(loadingPublisherWithData) { value1, value2 in
            XCTAssertEqual(value1, 70)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, 140)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_LoadingWithData_Completed() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisherWithData.combineState(completedPublisher) { value1, value2 in
            XCTAssertEqual(value1, 70)
            XCTAssertEqual(value2, 30)
            return value1 + value2
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, 100)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_LoadingWithData_Error() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = loadingPublisherWithData.combineState(errorPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_Completed_Loading() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = completedPublisher.combineState(loadingPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, nil)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Completed_LoadingWithData() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = completedPublisher.combineState(loadingPublisherWithData) { value1, value2 in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTAssertEqual(content, 100)
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Completed_Completed() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = completedPublisher.combineState(completedPublisher) { value1, value2 in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 30)
            return value1 + value2
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { content, _, _ in
                    XCTAssertEqual(content, 60)
                },
                onError: { _ in
                    XCTFail()
                }
            )
        }
    }

    func test_Combine_Completed_Error() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = completedPublisher.combineState(errorPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_Error_Loading() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = errorPublisher.combineState(loadingPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_Error_LoadingWithData() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = errorPublisher.combineState(loadingPublisherWithData) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_Error_Completed() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = errorPublisher.combineState(completedPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }

    func test_Combine_Error_Error() async throws {
        let combinedFlowState: LoadingStateSequence<Int> = errorPublisher.combineState(errorPublisher) { _, _ in
            XCTFail()
            fatalError()
        }
        for try await combinedState in combinedFlowState {
            combinedState.doAction(
                onLoading: { content in
                    XCTFail()
                },
                onCompleted: { _, _, _ in
                    XCTFail()
                },
                onError: { error in
                    XCTAssert(error is NoSuchElementError)
                }
            )
        }
    }
}

