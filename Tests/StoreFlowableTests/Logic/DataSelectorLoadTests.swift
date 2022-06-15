import XCTest
@testable import StoreFlowable

final class DataSelectorLoadTests: XCTestCase {

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
                    XCTFail()
                    fatalError()
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

    func test_Load_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil

        let data = await dataSelector.loadValidCacheOrNil()
        XCTAssertEqual(data, nil)
    }

    func test_Load_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = .validData

        let data = await dataSelector.loadValidCacheOrNil()
        guard case .validData = data else { return XCTFail() }
    }

    func test_Load_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = .invalidData

        let data = await dataSelector.loadValidCacheOrNil()
        XCTAssertEqual(data, nil)
    }
}
