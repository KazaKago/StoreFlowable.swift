import XCTest
import Combine
@testable import StoreFlowable

final class FlowStateMapperTests: XCTestCase {

    private let fixedStatePublisher: Just<State<Int>> = Just(.fixed(content: .wrap(rawContent: 30)))
    private var cancellableSet = Set<AnyCancellable>()

    func testMapContent() {
        fixedStatePublisher
            .mapContent { value in
                return value + 70
            }
            .sink { state in
                switch state {
                case .fixed:
                    break // ok
                case .loading:
                    XCTFail()
                case .error:
                    XCTFail()
                }
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

    static var allTests = [
        ("testMapContent", testMapContent),
    ]
}
