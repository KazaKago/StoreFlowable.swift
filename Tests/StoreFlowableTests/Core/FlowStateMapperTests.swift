import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class FlowStateMapperTests: XCTestCase {

    private let fixedStatePublisher: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: 30)))

    func testMapContent() throws {
        let recorder = fixedStatePublisher
            .mapContent { value in
                return value + 70
            }
            .record()
        let element = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(element.count, 1)
        switch element.first! {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        switch element.first!.content {
        case .exist(let rawContent):
            XCTAssertEqual(rawContent, 100)
        case .notExist:
            XCTFail()
        }
    }

    static var allTests = [
        ("testMapContent", testMapContent),
    ]
}
