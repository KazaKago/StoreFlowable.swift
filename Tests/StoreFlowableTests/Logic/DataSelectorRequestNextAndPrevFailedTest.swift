import XCTest
@testable import StoreFlowable

final class DataSelectorRequestNextAndPrevFailedTests: XCTestCase {

    private enum TestData: Equatable {
        case validData
        case invalidData
        case fetchedData
        case fetchedNextData
        case fetchedPrevData

        var needRefresh: Bool {
            switch self {
            case .validData: return false
            case .invalidData: return true
            case .fetchedData: return false
            case .fetchedNextData: return false
            case .fetchedPrevData: return false
            }
        }
    }

    private var dataSelector: DataSelector<[TestData]>!
    private var dataState: DataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
    private var dataCache: [TestData]? = nil
    private var nextRequestKey: String? = nil
    private var prevRequestKey: String? = nil

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
                    self.prevRequestKey
                },
                savePrev: { requestKey in
                    self.prevRequestKey = requestKey
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
                    self.dataCache = newData + cachedData
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
                    throw NoSuchElementError()
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

    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Loading_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Loading_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Loading_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Fixed_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = nil
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = nil
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = nil
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = nil
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = [.validData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .loading)
        dataCache = [.invalidData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = nil
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.validData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .fixed, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.invalidData]
        nextRequestKey = nil
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .fixed = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, nil)
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_NoCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_ValidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Loading_Loading_NoCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .loading)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Loading_ValidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .loading)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Loading_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .loading)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Loading_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .loading, prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .loading = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Fixed_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Fixed_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Fixed_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .fixed)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = nil

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .fixed = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, nil)
    }

    func test_RequestNextAndPrev_Fixed_Error_Loading_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .loading)
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Loading_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .loading)
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Loading_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .loading)
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .loading = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Error_NoCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = nil
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnNilException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .error(_, _, let rawError) = self.dataState {
            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, nil)
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Error_ValidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.validData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.validData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }

    func test_RequestNextAndPrev_Fixed_Error_Error_InvalidCache() async throws {
        dataState = .fixed(nextDataState: .error(rawError: NoSuchElementError()), prevDataState: .error(rawError: NoSuchElementError()))
        dataCache = [.invalidData]
        nextRequestKey = "INITIAL_KEY"
        prevRequestKey = "INITIAL_KEY"

        await dataSelector.requestNextData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")

        await dataSelector.requestPrevData(continueWhenError: true)
        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
            guard case .error = nextDataState else { return XCTFail() }
            guard case .error = prevDataState else { return XCTFail() }
        } else {
            XCTFail()
        }
        XCTAssertEqual(self.dataCache, [.invalidData])
        XCTAssertEqual(self.nextRequestKey, "INITIAL_KEY")
        XCTAssertEqual(self.prevRequestKey, "INITIAL_KEY")
    }
}
