import XCTest
@testable import StoreFlowable

final class StateZipperTest: XCTestCase {

    private let fixedExistState: State<Int> = .fixed(content: .wrap(rawContent: 30))
    private let loadingExistState: State<Int> = .loading(content: .wrap(rawContent: 70))
    private let errorExistState: State<Int> = .error(content: .wrap(rawContent: 130), rawError: NoSuchElementError())
    private let fixedNotExistState: State<Int> = .fixed(content: .wrap(rawContent: nil))

    func testZipWithFixedLoading() {
        let zippedState = fixedExistState.zip(loadingExistState) { value1, value2 -> Int in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        zippedState.doAction(
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
        zippedState.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 100)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithFixedError() {
        let zippedState = fixedExistState.zip(errorExistState) { value1, value2 -> Int in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 130)
            return value1 + value2
        }
        zippedState.doAction(
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
        zippedState.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 160)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithLoadingError() {
        let zippedState = loadingExistState.zip(errorExistState) { value1, value2 -> Int in
            XCTAssertEqual(value1, 70)
            XCTAssertEqual(value2, 130)
            return value1 + value2
        }
        zippedState.doAction(
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
        zippedState.content.doAction(
            onExist: { value in
                XCTAssertEqual(value, 200)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithFixedFixedNotExist() {
        let zippedState = fixedExistState.zip(fixedNotExistState) { value1, value2 -> Int in
            XCTFail()
            return value1 + value2
        }
        zippedState.doAction(
            onFixed: {
                //ok
            },
            onLoading: {
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
        zippedState.content.doAction(
            onExist: { _ in
                XCTFail()
            },
            onNotExist: {
                // ok
            }
        )
    }
}
