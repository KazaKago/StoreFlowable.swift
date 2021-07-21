import XCTest
@testable import StoreFlowable

final class LoadingStateTests: XCTestCase {

    func test_DoAction_Completed() {
        let state: LoadingState<Int> = .completed(content: 10, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true))
        state.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { content, _, _ in
                XCTAssertEqual(content, 10)
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_DoAction_Loading() {
        let state: LoadingState<Int> = .loading(content: nil)
        state.doAction(
            onLoading: { _ in
                // ok
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_DoAction_Error() {
        let state: LoadingState<Int> = .error(rawError: NoSuchElementError())
        state.doAction(
            onLoading: { _ in
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
