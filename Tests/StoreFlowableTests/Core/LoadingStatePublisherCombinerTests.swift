//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class LoadingStatePublisherCombinerTests: XCTestCase {
//
//    private let loadingPublisher: Just<LoadingState<Int>> = Just(.loading(content: nil))
//    private let loadingPublisherWithData: Just<LoadingState<Int>> = Just(.loading(content: 70))
//    private let completedPublisher: Just<LoadingState<Int>> = Just(.completed(content: 30, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true)))
//    private let errorPublisher: Just<LoadingState<Int>> = Just(.error(rawError: NoSuchElementError()))
//
//    func test_Combine_Loading_Loading() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisher.combineState(loadingPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, nil)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Loading_LoadingWithData() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisher.combineState(loadingPublisherWithData) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, nil)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Loading_Completed() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisher.combineState(completedPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, nil)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Loading_Error() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisher.combineState(errorPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_LoadingWithData_Loading() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisherWithData.combineState(loadingPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, nil)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_LoadingWithData_LoadingWithData() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisherWithData.combineState(loadingPublisherWithData) { value1, value2 in
//            XCTAssertEqual(value1, 70)
//            XCTAssertEqual(value2, 70)
//            return value1 + value2
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, 140)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_LoadingWithData_Completed() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisherWithData.combineState(completedPublisher) { value1, value2 in
//            XCTAssertEqual(value1, 70)
//            XCTAssertEqual(value2, 30)
//            return value1 + value2
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, 100)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_LoadingWithData_Error() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = loadingPublisherWithData.combineState(errorPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_Completed_Loading() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = completedPublisher.combineState(loadingPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, nil)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Completed_LoadingWithData() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = completedPublisher.combineState(loadingPublisherWithData) { value1, value2 in
//            XCTAssertEqual(value1, 30)
//            XCTAssertEqual(value2, 70)
//            return value1 + value2
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTAssertEqual(content, 100)
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Completed_Completed() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = completedPublisher.combineState(completedPublisher) { value1, value2 in
//            XCTAssertEqual(value1, 30)
//            XCTAssertEqual(value2, 30)
//            return value1 + value2
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { content, _, _ in
//                XCTAssertEqual(content, 60)
//            },
//            onError: { _ in
//                XCTFail()
//            }
//        )
//    }
//
//    func test_Combine_Completed_Error() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = completedPublisher.combineState(errorPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_Error_Loading() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = errorPublisher.combineState(loadingPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_Error_LoadingWithData() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = errorPublisher.combineState(loadingPublisherWithData) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_Error_Completed() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = errorPublisher.combineState(completedPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//
//    func test_Combine_Error_Error() throws {
//        let combinedFlowState: LoadingStatePublisher<Int> = errorPublisher.combineState(errorPublisher) { _, _ in
//            XCTFail()
//            fatalError()
//        }
//        let recorder = combinedFlowState.record()
//        let combinedState = try wait(for: recorder.next(), timeout: 1)
//        combinedState.doAction(
//            onLoading: { content in
//                XCTFail()
//            },
//            onCompleted: { _, _, _ in
//                XCTFail()
//            },
//            onError: { error in
//                XCTAssert(error is NoSuchElementError)
//            }
//        )
//    }
//}
