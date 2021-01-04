import XCTest
@testable import StoreFlowable

final class StateTests: XCTestCase {

    func testContent() {
        let state1: State<Int> = .fixed(content: .exist(rawContent: 0))
        switch state1.content {
        case .exist(let rawContent): XCTAssertEqual(rawContent, 0)
        case .notExist: XCTFail()
        }
        let state2: State<Int> = .fixed(content: .notExist)
        switch state2.content {
        case .exist: XCTFail()
        case .notExist: break // OK
        }
    }

    func testDoActionWithFixed() {
        let state: State<Int> = .fixed(content: .notExist)
        state.doAction(
            onFixed: {
                // OK
            },
            onLoading: {
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func testDoActionWithLoading() {
        let state: State<Int> = .loading(content: .notExist)
        state.doAction(
            onFixed: {
                XCTFail()
            },
            onLoading: {
                // OK
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func testDoActionWithError() {
        let state: State<Int> = .error(content: .notExist, rawError: NoSuchElementError())
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
    }

    static var allTests = [
        ("testContent", testContent),
        ("testDoActionWithFixed", testDoActionWithFixed),
        ("testDoActionWithLoading", testDoActionWithLoading),
        ("testDoActionWithError", testDoActionWithError),
    ]
}
