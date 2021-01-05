import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class StoreFlowableTests: XCTestCase {

    private enum TestData {
        case validData
        case invalidData
        case fetchedData

        var needRefresh: Bool {
            switch self {
            case .validData: return false
            case .invalidData: return true
            case .fetchedData: return false
            }
        }
    }

    private class TestResponder: StoreFlowableResponder {

        typealias KEY = String
        typealias DATA = TestData

        private var dataCache: TestData?

        init(dataCache: TestData?) {
            self.dataCache = dataCache
        }

        let key: String = "Key"

        let flowableDataStateManager: FlowableDataStateManager<String> = FlowableDataStateManager<String>()

        func loadData() -> AnyPublisher<TestData?, Never> {
            Just(dataCache)
                .eraseToAnyPublisher()
        }

        func saveData(data: TestData?) -> AnyPublisher<Void, Never> {
            Future { promise in
                self.dataCache = data
                promise(.success(()))
            }.eraseToAnyPublisher()
        }

        func fetchOrigin() -> AnyPublisher<TestData, Error> {
            fatalError()
        }

        func needRefresh(data: TestData) -> AnyPublisher<Bool, Never> {
            Just(data.needRefresh)
                .eraseToAnyPublisher()
        }
    }

    private class SucceedTestResponder: TestResponder {

        override init(dataCache: TestData?) {
            super.init(dataCache: dataCache)
        }

        override func fetchOrigin() -> AnyPublisher<TestData, Error> {
            Just(TestData.fetchedData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    private class FailedTestResponder: TestResponder {

        override init(dataCache: TestData?) {
            super.init(dataCache: dataCache)
        }

        override func fetchOrigin() -> AnyPublisher<TestData, Error> {
            Future { promise in
                promise(.failure(NoSuchElementError()))
            }.eraseToAnyPublisher()
        }
    }

    func testFlowWithNoCache() throws {
        // TODO
    }

    func testFlowWithValidCache() throws {
        // TODO
    }

    func testFlowWithInvalidCache() throws {
        // TODO
    }

    func testFlowFailedWithNoCache() throws {
        // TODO
    }

    func testFlowFailedWithValidCache() throws {
        // TODO
    }

    func testFlowFailedWithInvalidCache() throws {
        // TODO
    }

    func testGetFromMixWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            XCTFail()
        case .invalidData:
            XCTFail()
        case .fetchedData:
            break // ok
        }
    }

    func testGetFromMixWithValidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: .validData).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            break // ok
        case .invalidData:
            XCTFail()
        case .fetchedData:
            XCTFail()
        }
    }

    func testGetFromMixWithInvalidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: .invalidData).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            XCTFail()
        case .invalidData:
            XCTFail()
        case .fetchedData:
            break // ok
        }
    }

    func testGetFromCacheWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFromCacheWithValidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: .validData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            break // ok
        case .invalidData:
            XCTFail()
        case .fetchedData:
            XCTFail()
        }
    }

    func testGetFromCacheWithInvalidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: .invalidData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFromOriginWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            XCTFail()
        case .invalidData:
            XCTFail()
        case .fetchedData:
            break // ok
        }
    }

    func testGetFromOriginWithValidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            XCTFail()
        case .invalidData:
            XCTFail()
        case .fetchedData:
            break // ok
        }
    }

    func testGetFromOriginWithInvalidCache() throws {
        let storeFlowable = SucceedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            XCTFail()
        case .invalidData:
            XCTFail()
        case .fetchedData:
            break // ok
        }
    }

    func testGetFailedFromMixWithNoCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromMixWithValidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: .validData).create()
        let recorder = storeFlowable.get(type: .mix).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            break // ok
        case .invalidData:
            XCTFail()
        case .fetchedData:
            XCTFail()
        }
    }

    func testGetFailedFromMixWithInvalidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: .invalidData).create()
        let recorder = storeFlowable.get(type: .mix).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromCacheWithNoCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromCacheWithValidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: .validData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        let elements = try wait(for: recorder.elements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements.first! {
        case .validData:
            break // ok
        case .invalidData:
            XCTFail()
        case .fetchedData:
            XCTFail()
        }
    }

    func testGetFailedFromCacheWithInvalidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: .invalidData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromOriginWithNoCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromOriginWithValidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: .validData).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testGetFailedFromOriginWithInvalidCache() throws {
        let storeFlowable = FailedTestResponder(dataCache: nil).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.elements, timeout: 1))
    }

    func testUpdateData() throws {
        // TODO
    }

    func testUpdateNull() throws {
        // TODO
    }

    func testValidateWithNoCache() throws {
        // TODO
    }

    func testValidateWithValidData() throws {
        // TODO
    }

    func testValidateWithInvalidData() throws {
        // TODO
    }

    func testRefresh() throws {
        // TODO
    }
}
