import XCTest
@testable import StoreFlowable

final class LoadingStateSequenceMapperTests: XCTestCase {

    private let completedSequence = AsyncStream<LoadingState<Int>> { continuation in
        continuation.yield(.completed(content: 30, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true)))
        continuation.finish()
    }

    func testMapContent() async throws {
        let stream = completedSequence.mapContent { value in
            value + 70
        }
        for try await state in stream {
            switch state {
            case .loading:
                XCTFail()
            case .completed(let content, _, _):
                XCTAssertEqual(content, 100)
            case .error:
                XCTFail()
            }
        }
    }
}
