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
        let recorder = flowableDataStateManager.getFlow(key: "hoge").record()
        switch try wait(for: recorder.next(), timeout: 1) {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        flowableDataStateManager.save(key: "hoge", state: .loading)
        switch try wait(for: recorder.next(), timeout: 1) {
        case .fixed:
            XCTFail()
        case .loading:
            break // ok
        case .error:
            XCTFail()
        }
        flowableDataStateManager.save(key: "hoge", state: .error(rawError: NoSuchElementError()))
        switch try wait(for: recorder.next(), timeout: 1) {
        case .fixed:
            XCTFail()
        case .loading:
            XCTFail()
        case .error:
            break // ok
        }
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 3)
    }

    func testFlowDifferentKeyEvent() throws {
        let recorder = flowableDataStateManager.getFlow(key: "hoge").record()
        flowableDataStateManager.save(key: "hogehoge", state: .loading)
        flowableDataStateManager.save(key: "hugahuga", state: .error(rawError: NoSuchElementError()))
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
    }
}
