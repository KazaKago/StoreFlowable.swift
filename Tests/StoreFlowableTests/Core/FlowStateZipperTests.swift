import XCTest
import Combine
@testable import StoreFlowable

final class FlowStateZipperTests: XCTestCase {

    private let flowFixedExist: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: 30)))
    private let flowFixedNotExist: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: nil)))
    private let flowLoadingExist: Just<State<Int>> = Just(.loading(content: .wrap(rawContent: 70)))
    private let flowErrorExist: Just<State<Int>> = Just(.error(content: .wrap(rawContent: 130), rawError: NoSuchElementError()))
    private var cancellableSet = Set<AnyCancellable>()

    func testZipWithFixedLoading() {
        flowFixedExist
            .zipState(flowLoadingExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 30)
                XCTAssertEqual(value2, 70)
                return value1 + value2
            }
            .sink { state in
                state.doAction(
                    onFixed: {
                        XCTFail()
                    },
                    onLoading: {
                        // ok
                    },
                    onError: { _ in
                        XCTFail()
                    }
                )
                state.content.doAction(
                    onExist: { value in
                        XCTAssertEqual(value, 100)
                    },
                    onNotExist: {
                        XCTFail()
                    }
                )
            }
            .store(in: &cancellableSet)
    }

    func testZipWithFixedError() {
        flowFixedExist
            .zipState(flowErrorExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 30)
                XCTAssertEqual(value2, 130)
                return value1 + value2
            }
            .sink { state in
                state.doAction(
                    onFixed: {
                        XCTFail()
                    },
                    onLoading: {
                        XCTFail()
                    },
                    onError: { error in
                        XCTAssert(error is NoSuchElementError)
                    }
                )
                state.content.doAction(
                    onExist: { value in
                        XCTAssertEqual(value, 160)
                    },
                    onNotExist: {
                        XCTFail()
                    }
                )
            }
            .store(in: &cancellableSet)
    }

    func testZipWithLoadingError() {
        flowLoadingExist
            .zipState(flowErrorExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 70)
                XCTAssertEqual(value2, 130)
                return value1 + value2
            }
            .sink { state in
                state.doAction(
                    onFixed: {
                        XCTFail()
                    },
                    onLoading: {
                        XCTFail()
                    },
                    onError: { error in
                        XCTAssert(error is NoSuchElementError)
                    }
                )
                state.content.doAction(
                    onExist: { value in
                        XCTAssertEqual(value, 200)
                    },
                    onNotExist: {
                        XCTFail()
                    }
                )
            }
            .store(in: &cancellableSet)
    }

    func testZipWithFixedFixed() {
        flowFixedExist
            .zipState(flowFixedNotExist) { value1, value2 -> Int in
                XCTFail()
                return value1 + value2
            }
            .sink { state in
                state.doAction(
                    onFixed: {
                        // ok
                    },
                    onLoading: {
                        XCTFail()
                    },
                    onError: { _ in
                        XCTFail()
                    }
                )
                state.content.doAction(
                    onExist: { _ in
                        XCTFail()
                    },
                    onNotExist: {
                        // ok
                    }
                )
            }
            .store(in: &cancellableSet)
    }

    static var allTests = [
        ("testZipWithFixedLoading", testZipWithFixedLoading),
        ("testZipWithFixedError", testZipWithFixedError),
        ("testZipWithLoadingError", testZipWithLoadingError),
        ("testZipWithFixedFixed", testZipWithFixedFixed),
    ]
}
