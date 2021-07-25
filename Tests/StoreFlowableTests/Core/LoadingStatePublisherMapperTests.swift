import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class LoadingStatePublisherMapperTests: XCTestCase {

    private let completedPublisher: Just<LoadingState<Int>> = Just(.completed(content: 30, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true)))

    func testMapContent() throws {
        let recorder = completedPublisher.mapContent { value in
            value + 70
        }.record()
        let element = try wait(for: recorder.next(), timeout: 1)
        switch element {
        case .loading:
            XCTFail()
        case .completed(let content, _, _):
            XCTAssertEqual(content, 100)
        case .error:
            XCTFail()
        }
    }
}
