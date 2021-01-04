import XCTest
@testable import StoreFlowable

final class StateContentZipperTests: XCTestCase {

    private let exist1: StateContent<Int> = .wrap(rawContent: 30)
    private let exist2: StateContent<Int> = .wrap(rawContent: 70)
    private let notExist1: StateContent<Int> = .wrap(rawContent: nil)
    private let notExist2: StateContent<Int> = .wrap(rawContent: nil)

    func testZipWithExistExist() {
        let zippedContent = exist1.zip(exist2) { value1, value2 -> Int in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        zippedContent.doAction(
            onExist: { value in
                XCTAssertEqual(value, 100)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testZipWithExistNotExist() {
        let zippedContent = exist1.zip(notExist1) { value1, value2 -> Int in
            XCTFail()
            return value1 + value2
        }
        zippedContent.doAction(
            onExist: { _ in
                XCTFail()
            },
            onNotExist: {
                // ok
            }
        )
    }

    func testZipWithNotExistNotExist() {
        let zippedContent = notExist1.zip(notExist2) { value1, value2 -> Int in
            XCTFail()
            return value1 + value2
        }
        zippedContent.doAction(
            onExist: { _ in
                XCTFail()
            },
            onNotExist: {
                // ok
            }
        )
    }

    static var allTests = [
        ("testZipWithExistExist", testZipWithExistExist),
        ("testZipWithExistNotExist", testZipWithExistNotExist),
        ("testZipWithNotExistNotExist", testZipWithNotExistNotExist),
    ]
}
