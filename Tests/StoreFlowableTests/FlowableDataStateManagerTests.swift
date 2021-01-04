import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class FlowableDataStateManagerTests: XCTestCase {

    private var flowableDataStateManager: FlowableDataStateManager<String>!

    override func setUp() {
        flowableDataStateManager = FlowableDataStateManager()
    }

    func testFlowSameKeyEvent() throws {
        //TODO
    }

    func testFlowDifferentKeyEvent() throws {
        //TODO
    }

    static var allTests = [
        ("testFlowSameKeyEvent", testFlowSameKeyEvent),
        ("testFlowDifferentKeyEvent", testFlowDifferentKeyEvent),
    ]
}
