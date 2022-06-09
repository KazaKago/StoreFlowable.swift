//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class StoreFlowableRequiredDataFailedTests: XCTestCase {
//
//    private enum TestData {
//        case validData
//        case invalidData
//        case fetchedData
//
//        var needRefresh: Bool {
//            switch self {
//            case .validData: return false
//            case .invalidData: return true
//            case .fetchedData: return false
//            }
//        }
//    }
//
//    private class TestFlowableFactory: StoreFlowableFactory {
//
//        typealias PARAM = UnitHash
//        typealias DATA = TestData
//
//        private var dataCache: TestData?
//
//        init(dataCache: TestData?) {
//            self.dataCache = dataCache
//        }
//
//        let flowableDataStateManager: FlowableDataStateManager<UnitHash> = FlowableDataStateManager<UnitHash>()
//
//        func loadDataFromCache(param: UnitHash) -> AnyPublisher<TestData?, Never> {
//            Just(dataCache).eraseToAnyPublisher()
//        }
//
//        func saveDataToCache(newData: TestData?, param: UnitHash) -> AnyPublisher<Void, Never> {
//            Future { promise in
//                self.dataCache = newData
//                promise(.success(()))
//            }.eraseToAnyPublisher()
//        }
//
//        func fetchDataFromOrigin(param: UnitHash) -> AnyPublisher<TestData, Error> {
//            Fail(error: NoSuchElementError()).eraseToAnyPublisher()
//        }
//
//        func needRefresh(cachedData: TestData, param: UnitHash) -> AnyPublisher<Bool, Never> {
//            Just(cachedData.needRefresh).eraseToAnyPublisher()
//        }
//    }
//
//    func test_RequiredData_Both_NoCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: nil).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .both).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Both_ValidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .validData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .both).record()
//        let element = try wait(for: recorder.next(), timeout: 1)
//        guard case .validData = element else { return XCTFail() }
//    }
//
//    func test_RequiredData_Both_InvalidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .invalidData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .both).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Cache_NoCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: nil).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .cache).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Cache_ValidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .validData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .cache).record()
//        let element = try wait(for: recorder.next(), timeout: 1)
//        guard case .validData = element else { return XCTFail() }
//    }
//
//    func test_RequiredData_Cache_InvalidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .invalidData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .cache).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Origin_NoCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: nil).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .origin).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Origin_ValidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .validData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .origin).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//
//    func test_RequiredData_Origin_InvalidCache() throws {
//        let storeFlowable = TestFlowableFactory(dataCache: .invalidData).create(UnitHash())
//        let recorder = storeFlowable.requireData(from: .origin).record()
//        let recording = try wait(for: recorder.recording, timeout: 1)
//        if case let .failure(error) = recording.completion {
//            XCTAssert(error is NoSuchElementError)
//        } else {
//            XCTFail()
//        }
//    }
//}
