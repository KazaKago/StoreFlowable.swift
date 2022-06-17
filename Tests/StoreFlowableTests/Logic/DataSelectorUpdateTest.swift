import XCTest
@testable import StoreFlowable

final class DataSelectorUpdateTests: XCTestCase {

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
                    InternalFetched(data: .fetchedData, nextKey: nil, prevKey: nil)
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

    func test_Update_Data() async throws {
        dataState = .loading()
        dataCache = nil

        await dataSelector.update(newData: .fetchedData, nextKey: nil, prevKey: nil)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, .fetchedData)
    }

    func test_Update_Nil() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = .invalidData

        await dataSelector.update(newData: nil, nextKey: nil, prevKey: nil)
        guard case .fixed = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
    }
}
