import XCTest
@testable import StoreFlowable

final class StateContentTests: XCTestCase {

    func testWrap() {
        let content1: StateContent<Int> = .wrap(rawContent: 30)
        switch content1 {
        case .exist(let rawContent): XCTAssertEqual(rawContent, 30)
        case .notExist: XCTFail()
        }
        let content2: StateContent<Int> = .wrap(rawContent: nil)
        switch content2 {
        case .exist: XCTFail()
        case .notExist: break // OK
        }
    }

    func testRawContent() {
        let content1: StateContent<Int> = .exist(rawContent: 30)
        switch content1 {
        case .exist(let rawContent): XCTAssertEqual(rawContent, 30)
        case .notExist: XCTFail()
        }
        let content2: StateContent<String> = .exist(rawContent: "Hello World!")
        switch content2 {
        case .exist(let rawContent): XCTAssertEqual(rawContent, "Hello World!")
        case .notExist: XCTFail()
        }
    }

    func testDoActionWithExist() {
        let content: StateContent<Int> = .exist(rawContent: 30)
        content.doAction(
            onExist: { rawContent in
                XCTAssertEqual(rawContent, 30)
            },
            onNotExist: {
                XCTFail()
            }
        )
    }

    func testDoActionWithNotExist() {
        let content: StateContent<Int> = .notExist
        content.doAction(
            onExist: { _ in
                XCTFail()
            },
            onNotExist: {
                // OK
            }
        )
    }
}
