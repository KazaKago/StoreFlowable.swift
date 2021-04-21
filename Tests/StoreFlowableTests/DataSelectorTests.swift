import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class DataSelectorTest: XCTestCase {

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

    private class TestDataStateManager: DataStateManager {
        typealias KEY = String
        var dataState: DataState = .fixed()
        func loadState(key: String) -> DataState {
            return dataState
        }
        func saveState(key: String, state: DataState) {
            dataState = state
        }
    }

    private class TestCacheDataManager : CacheDataManager {
        typealias DATA = TestData
        var dataCache: TestData? = nil
        func loadDataFromCache() -> AnyPublisher<TestData?, Never> {
            Just(dataCache)
                .eraseToAnyPublisher()
        }
        func saveDataToCache(newData: TestData?) -> AnyPublisher<Void, Never> {
            Future { promise in
                self.dataCache = newData
                promise(.success(()))
            }.eraseToAnyPublisher()
        }
    }

    private class TestOriginDataManager : OriginDataManager {
        typealias DATA = TestData
        func fetchDataFromOrigin() -> AnyPublisher<FetchingResult<DataSelectorTest.TestData>, Error> {
            Future { promise in
                promise(.success(FetchingResult(data: .fetchedData)))
            }.eraseToAnyPublisher()
        }
    }

    private let testDataStateManager = TestDataStateManager()
    private let testCacheDataManager = TestCacheDataManager()
    private let testOriginDataManager = TestOriginDataManager()
    private var dataSelector: DataSelector<String, TestData>!

    override func setUp() {
        dataSelector = DataSelector(
            key: "key",
            dataStateManager: AnyDataStateManager(testDataStateManager),
            cacheDataManager: AnyCacheDataManager(testCacheDataManager),
            originDataManager: AnyOriginDataManager(testOriginDataManager),
            needRefresh: { value in Just(value.needRefresh).eraseToAnyPublisher() }
        )
    }

    private func setupFixedStatNoCache() {
        testDataStateManager.dataState = .fixed()
        testCacheDataManager.dataCache = nil
    }

    private func setupLoadingStateNoCache() {
        testDataStateManager.dataState = .loading
        testCacheDataManager.dataCache = nil
    }

    private func setupErrorStateNoCache() {
        testDataStateManager.dataState = .error(rawError: NoSuchElementError())
        testCacheDataManager.dataCache = nil
    }

    private func setupFixedStateValidCache() {
        testDataStateManager.dataState = .fixed()
        testCacheDataManager.dataCache = .validData
    }

    private func setupLoadingStateValidCache() {
        testDataStateManager.dataState = .loading
        testCacheDataManager.dataCache = .validData
    }

    private func setupErrorStateValidCache() {
        testDataStateManager.dataState = .error(rawError: NoSuchElementError())
        testCacheDataManager.dataCache = .validData
    }

    private func setupFixedStateInvalidData() {
        testDataStateManager.dataState = .fixed()
        testCacheDataManager.dataCache = .invalidData
    }

    func testDoActionWithFixedStateNoCache() throws {
        var recorder: Recorder<Void, Never>!

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStatNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }
    }

    func testDoActionWithLoadingStateNoCache() throws {
        var recorder: Recorder<Void, Never>!

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupLoadingStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        XCTAssertNil(testCacheDataManager.dataCache)
    }

    func testDoActionWithErrorStateNoCache() throws {
        var recorder: Recorder<Void, Never>!

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        XCTAssertNil(testCacheDataManager.dataCache)

        setupErrorStateNoCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }
    }

    func testDoActionWithFixedStateValidCache() throws {
        var recorder: Recorder<Void, Never>!

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }
    }

    func testDoActionWithLoadingStateValidCache() throws {
        var recorder: Recorder<Void, Never>!

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupLoadingStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: break // ok
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }
    }

    func testDoActionWithErrorStateValidCache() throws {
        var recorder: Recorder<Void, Never>!

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: XCTFail()
        case .loading: XCTFail()
        case .error: break // ok
        }
        switch testCacheDataManager.dataCache! {
        case .validData: break // ok
        case .invalidData: XCTFail()
        case .fetchedData: XCTFail()
        }

        setupErrorStateValidCache()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }
    }

    func testDoActionWithFixedStateInvalidData() throws {
        var recorder: Recorder<Void, Never>!

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: false, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }

        setupFixedStateInvalidData()
        recorder = dataSelector.doStateAction(forceRefresh: true, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true).record()
        _ = try wait(for: recorder.finished, timeout: 1)
        switch testDataStateManager.dataState {
        case .fixed: break // ok
        case .loading: XCTFail()
        case .error: XCTFail()
        }
        switch testCacheDataManager.dataCache! {
        case .validData: XCTFail()
        case .invalidData: XCTFail()
        case .fetchedData: break // ok
        }
    }
}
