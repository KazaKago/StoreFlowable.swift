import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class FlowStateZipperTests: XCTestCase {

    private let flowFixedExist: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: 30)))
    private let flowFixedNotExist: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: nil)))
    private let flowLoadingExist: Just<State<Int>> = Just(.loading(content: .wrap(rawContent: 70)))
    private let flowErrorExist: Just<State<Int>> = Just(.error(content: .wrap(rawContent: 130), rawError: NoSuchElementError()))

    func testZipWithFixedLoading() throws {
        let recorder = flowFixedExist
            .zipState(flowLoadingExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 30)
                XCTAssertEqual(value2, 70)
                return value1 + value2
            }
            .record()
        let element = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(element.count, 1)
        element.first!.doAction(
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
        element.first!.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 100)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithFixedError() throws {
        let recorder = flowFixedExist
            .zipState(flowErrorExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 30)
                XCTAssertEqual(value2, 130)
                return value1 + value2
            }
            .record()
        let element = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(element.count, 1)
        element.first!.doAction(
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
        element.first!.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 160)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithLoadingError() throws {
        let recorder = flowLoadingExist
            .zipState(flowErrorExist) { value1, value2 -> Int in
                XCTAssertEqual(value1, 70)
                XCTAssertEqual(value2, 130)
                return value1 + value2
            }
            .record()
        let element = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(element.count, 1)
        element.first!.doAction(
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
        element.first!.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 200)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithFixedFixed() throws {
        let recorder = flowFixedExist
            .zipState(flowFixedNotExist) { value1, value2 -> Int in
                XCTFail()
                return value1 + value2
            }
            .record()
        let element = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(element.count, 1)
        element.first!.doAction(
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
        element.first!.content.doAction(
            onExist: { _ in
                XCTFail()
            },
            onNotExist: {
                // ok
            }
        )
    }

    static var allTests = [
        ("testZipWithFixedLoading", testZipWithFixedLoading),
        ("testZipWithFixedError", testZipWithFixedError),
        ("testZipWithLoadingError", testZipWithLoadingError),
        ("testZipWithFixedFixed", testZipWithFixedFixed),
    ]
}
