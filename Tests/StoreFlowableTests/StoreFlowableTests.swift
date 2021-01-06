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
        private let fetchingData: Future<TestData, Error>

        init(initialData: TestData?, fetchingData: Future<TestData, Error>) {
            dataCache = initialData
            self.fetchingData = fetchingData
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
            fetchingData
                .delay(for: .seconds(0.1), scheduler: RunLoop.main) // dummy delay
                .eraseToAnyPublisher()
        }

        func needRefresh(data: TestData) -> AnyPublisher<Bool, Never> {
            Just(data.needRefresh)
                .eraseToAnyPublisher()
        }
    }

    private class SucceedTestResponder: TestResponder {

        init(initialData: TestData?) {
            let fetchingData = Future<TestData, Error> { promise in
                promise(.success(.fetchedData))
            }
            super.init(initialData: initialData, fetchingData: fetchingData)
        }
    }

    private class FailedTestResponder: TestResponder {

        init(initialData: TestData?) {
            let fetchingData = Future<TestData, Error> { promise in
                promise(.failure(NoSuchElementError()))
            }
            super.init(initialData: initialData, fetchingData: fetchingData)
        }
    }

    func testFlowWithNoCache() throws {
//        let storeFlowable = SucceedTestResponder(initialData: nil).create()
//        let recorder = storeFlowable.publish().record()
//        let elements = try wait(for: recorder.availableElements, timeout: 1)
//        XCTAssertEqual(elements.count, 2)
//        switch elements[0] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            break // ok
//        case .error:
//            XCTFail()
//        }
//        switch elements[0].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
//        switch elements[1] {
//        case .fixed:
//            break // ok
//        case .loading:
//            XCTFail()
//        case .error:
//            XCTFail()
//        }
//        switch elements[1].content {
//        case .exist:
//            break // ok
//        case .notExist:
//            XCTFail()
//        }
    }

    func testFlowWithValidCache() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements[0] {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        switch elements[0].content {
        case .exist:
            break // ok
        case .notExist:
            XCTFail()
        }
    }

    func testFlowWithInvalidCache() throws {
//        let storeFlowable = SucceedTestResponder(initialData: .invalidData).create()
//        let recorder = storeFlowable.publish().record()
//        let elements = try wait(for: recorder.availableElements, timeout: 1)
//        XCTAssertEqual(elements.count, 2)
//        switch elements[0] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            break // ok
//        case .error:
//            XCTFail()
//        }
//        switch elements[0].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
//        switch elements[1] {
//        case .fixed:
//            break // ok
//        case .loading:
//            XCTFail()
//        case .error:
//            XCTFail()
//        }
//        switch elements[1].content {
//        case .exist:
//            break // ok
//        case .notExist:
//            XCTFail()
//        }
    }

    func testFlowFailedWithNoCache() throws {
//        let storeFlowable = FailedTestResponder(initialData: nil).create()
//        let recorder = storeFlowable.publish().record()
//        let elements = try wait(for: recorder.availableElements, timeout: 1)
//        XCTAssertEqual(elements.count, 2)
//        switch elements[0] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            break // ok
//        case .error:
//            XCTFail()
//        }
//        switch elements[0].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
//        switch elements[1] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            XCTFail()
//        case .error:
//            break // ok
//        }
//        switch elements[1].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
    }

    func testFlowFailedWithValidCache() throws {
        let storeFlowable = FailedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 1)
        switch elements[0] {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        switch elements[0].content {
        case .exist:
            break // ok
        case .notExist:
            XCTFail()
        }
    }

    func testFlowFailedWithInvalidCache() throws {
//        let storeFlowable = FailedTestResponder(initialData: .invalidData).create()
//        let recorder = storeFlowable.publish().record()
//        let elements = try wait(for: recorder.availableElements, timeout: 1)
//        XCTAssertEqual(elements.count, 2)
//        switch elements[0] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            break // ok
//        case .error:
//            XCTFail()
//        }
//        switch elements[0].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
//        switch elements[1] {
//        case .fixed:
//            XCTFail()
//        case .loading:
//            XCTFail()
//        case .error:
//            break // ok
//        }
//        switch elements[1].content {
//        case .exist:
//            XCTFail()
//        case .notExist:
//            break // ok
//        }
    }

    func testGetFromMixWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(initialData: nil).create()
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
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
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
        let storeFlowable = SucceedTestResponder(initialData: .invalidData).create()
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
        let storeFlowable = SucceedTestResponder(initialData: nil).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFromCacheWithValidCache() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
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
        let storeFlowable = SucceedTestResponder(initialData: .invalidData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFromOriginWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(initialData: nil).create()
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
        let storeFlowable = SucceedTestResponder(initialData: nil).create()
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
        let storeFlowable = SucceedTestResponder(initialData: nil).create()
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
        let storeFlowable = FailedTestResponder(initialData: nil).create()
        let recorder = storeFlowable.get(type: .mix).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromMixWithValidCache() throws {
        let storeFlowable = FailedTestResponder(initialData: .validData).create()
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
        let storeFlowable = FailedTestResponder(initialData: .invalidData).create()
        let recorder = storeFlowable.get(type: .mix).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromCacheWithNoCache() throws {
        let storeFlowable = FailedTestResponder(initialData: nil).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromCacheWithValidCache() throws {
        let storeFlowable = FailedTestResponder(initialData: .validData).create()
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
        let storeFlowable = FailedTestResponder(initialData: .invalidData).create()
        let recorder = storeFlowable.get(type: .fromCache).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromOriginWithNoCache() throws {
        let storeFlowable = FailedTestResponder(initialData: nil).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromOriginWithValidCache() throws {
        let storeFlowable = FailedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testGetFailedFromOriginWithInvalidCache() throws {
        let storeFlowable = FailedTestResponder(initialData: nil).create()
        let recorder = storeFlowable.get(type: .fromOrigin).record()
        XCTAssertThrowsError(try wait(for: recorder.finished, timeout: 1))
    }

    func testUpdateData() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let publishRecorder = storeFlowable.publish().record()
        _ = try wait(for: publishRecorder.next(), timeout: 1)
        let updateRecorder = storeFlowable.update(newData: .validData).record()
        _ = try wait(for: updateRecorder.finished, timeout: 1)
        let element = try wait(for: publishRecorder.next(), timeout: 1)
        switch element {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        switch element.content {
        case .exist(let rawContent):
            XCTAssertEqual(rawContent, .validData)
        case .notExist:
            XCTFail()
        }
    }

    func testUpdateNil() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let publishRecorder = storeFlowable.publish().record()
        _ = try wait(for: publishRecorder.next(), timeout: 1)
        _ = storeFlowable.update(newData: nil).record()
        let element = try wait(for: publishRecorder.next(), timeout: 1)
        switch element {
        case .fixed:
            break // ok
        case .loading:
            XCTFail()
        case .error:
            XCTFail()
        }
        switch element.content {
        case .exist:
            XCTFail()
        case .notExist:
            break // ok
        }
    }

    func testValidateWithNoCache() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.update(newData: nil).record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.validate().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 4)
    }

    func testValidateWithValidData() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.update(newData: .validData).record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.validate().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 2)
    }

    func testValidateWithInvalidData() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.update(newData: .invalidData).record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.validate().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 4)
    }

    func testRefresh() throws {
        let storeFlowable = SucceedTestResponder(initialData: .validData).create()
        let recorder = storeFlowable.publish().record()
        _ = try wait(for: recorder.next(), timeout: 1)
        _ = storeFlowable.refresh().record()
        let elements = try wait(for: recorder.availableElements, timeout: 1)
        XCTAssertEqual(elements.count, 3)
    }
}
