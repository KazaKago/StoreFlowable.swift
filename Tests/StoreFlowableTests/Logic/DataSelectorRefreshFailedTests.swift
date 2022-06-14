import XCTest
@testable import StoreFlowable

final class DataSelectorRefreshFailedTests: XCTestCase {

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

    private var dataSelector: DataSelector<TestData>!
    private var dataState: DataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
    private var dataCache: TestData? = nil

    override func setUp() {
        dataSelector = DataSelector(
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    XCTFail()
                    fatalError()
                },
                saveNext: { requestKey in
                    // do nothing.
                },
                loadPrev: {
                    XCTFail()
                    fatalError()
                },
                savePrev: { requestKey in
                    // do nothing.
                }
            ),
            cacheDataManager: AnyCacheDataManager(
                load: {
                    self.dataCache
                },
                save: { newData in
                    self.dataCache = newData
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
                    throw NoSuchElementError()
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
            dataStateManager: AnyDataStateManager(
                load: {
                    self.dataState
                },
                save: { dataState in
                    self.dataState = dataState
                }
            ),
            needRefresh: { value in value.needRefresh }
        )
    }

    func test_Refresh_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = .validData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = .invalidData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Loading_NoCache() async throws {
        dataState = .loading()
        dataCache = nil

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Loading_ValidCache() async throws {
        dataState = .loading()
        dataCache = .validData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .validData)
    }

    func test_Refresh_Loading_InvalidCache() async throws {
        dataState = .loading()
        dataCache = .invalidData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .invalidData)
    }

    func test_Refresh_Error_NoCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = nil

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Error_ValidCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = .validData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }

    func test_Refresh_Error_InvalidCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = .invalidData

        await dataSelector.refresh(clearCacheBeforeFetching: true)
        guard case .error = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }
}
