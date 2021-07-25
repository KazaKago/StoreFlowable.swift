import XCTest
import Combine
import CombineExpectations
@testable import StoreFlowable

final class DataSelectorRefreshTests: XCTestCase {

    private enum TestData: Equatable {
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

    private var dataSelector: DataSelector<String, TestData>!
    private var dataState: DataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
    private var dataCache: TestData? = nil

    override func setUp() {
        dataSelector = DataSelector(
            key: "key",
            dataStateManager: AnyDataStateManager(
                load: { key in
                    self.dataState
                },
                save: { key, dataState in
                    self.dataState = dataState
                }
            ),
            cacheDataManager: AnyCacheDataManager(
                load: {
                    Just(self.dataCache).eraseToAnyPublisher()
                },
                save: { newData in
                    Future { promise in
                        self.dataCache = newData
                        promise(.success(()))
                    }.eraseToAnyPublisher()
                },
                saveNext: { cachedData, newData in
                    XCTFail()
                    fatalError()
                },
                savePrev: { cachedData, newData in
                    XCTFail()
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager(
                fetch: {
                    Just(InternalFetched(data: .fetchedData, nextKey: nil, prevKey: nil))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    XCTFail()
                    fatalError()
                },
                fetchPrev: { prevKey in
                    XCTFail()
                    fatalError()
                }
            ),
            needRefresh: { value in Just(value.needRefresh).eraseToAnyPublisher() }
        )
    }

    func test_Refresh_Fixed_NoCache() throws {
        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
        dataCache = nil

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Refresh_Fixed_ValidCache() throws {
        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
        dataCache = .validData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Refresh_Fixed_InvalidCache() throws {
        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
        dataCache = .invalidData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Refresh_Loading_NoCache() throws {
        dataState = .loading
        dataCache = nil

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Loading_ValidCache() throws {
        dataState = .loading
        dataCache = .validData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .validData)
    }

    func test_Refresh_Loading_InvalidCache() throws {
        dataState = .loading
        dataCache = .invalidData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .invalidData)
    }

    func test_Refresh_Error_NoCache() throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = nil

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Refresh_Error_ValidCache() throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = .validData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Refresh_Error_InvalidCache() throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = .invalidData

        let recorder = dataSelector.refresh(clearCacheBeforeFetching: true).record()
        _ = try wait(for: recorder.elements, timeout: 1)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }
}
