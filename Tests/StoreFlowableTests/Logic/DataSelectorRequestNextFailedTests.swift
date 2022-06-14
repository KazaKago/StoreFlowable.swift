import XCTest
@testable import StoreFlowable

final class DataSelectorRequestNextFailedTests: XCTestCase {

    private enum TestData: Equatable {
        case validData
        case invalidData
        case fetchedData
        case fetchedNextData

        var needRefresh: Bool {
            switch self {
            case .validData: return false
            case .invalidData: return true
            case .fetchedData: return false
            case .fetchedNextData: return false
            }
        }
    }

    private var dataSelector: DataSelector<[TestData]>!
    private var dataState: DataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
    private var dataCache: [TestData]? = nil
    private var nextRequestKey: String? = nil

    override func setUp() {
        dataSelector = DataSelector(
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    self.nextRequestKey
                },
                saveNext: { requestKey in
                    self.nextRequestKey = requestKey
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
                    XCTFail()
                    fatalError()
                },
                saveNext: { cachedData, newData in
                    self.dataCache = cachedData + newData
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
                    throw NoSuchElementError()
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
            needRefresh: { value in value.first?.needRefresh == true }
        )
    }

    func test_RequestNextData_Fixed_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_FixedWithNoMoreData_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Fixed_FixedWithNoMoreData_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Fixed_FixedWithNoMoreData_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Fixed_Loading_NoCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Loading_ValidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Loading_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Fixed_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_Loading_NoCache() async throws {
        dataState = .loading()
        dataCache = nil
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Loading_ValidCache() async throws {
        dataState = .loading()
        dataCache = [.validData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Loading_InvalidCache() async throws {
        dataState = .loading()
        dataCache = [.invalidData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        guard case .loading = self.dataState else { return XCTFail() }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Error_NoCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = nil
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Error_ValidCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = [.validData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_Error_InvalidCache() async throws {
        dataState = .error(rawError: NoSuchElementError())
        dataCache = [.invalidData]
        nextRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
    }

    func test_RequestNextData_NonContinueWhenError_Fixed_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: false)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_NonContinueWhenError_Fixed_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: false)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextData_NonContinueWhenError_Fixed_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: false)
        if case .fixed(let nextDataState, _) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
    }
}
