//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class DataSelectorRequestNextAndPrevFailedTests: XCTestCase {
//
//    private enum TestData: Equatable {
//        case validData
//        case invalidData
//        case fetchedData
//        case fetchedNextData
//        case fetchedPrevData
//
//        var needRefresh: Bool {
//            switch self {
//            case .validData: return false
//            case .invalidData: return true
//            case .fetchedData: return false
//            case .fetchedNextData: return false
//            case .fetchedPrevData: return false
//            }
//        }
//    }
//
//    private var dataSelector: DataSelector<UnitHash, [TestData]>!
//    private var dataState: DataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//    private var dataCache: [TestData]? = nil
//
//    override func setUp() {
//        dataSelector = DataSelector(
//            param: UnitHash(),
//            dataStateManager: AnyDataStateManager(
//                load: { key in
//                    self.dataState
//                },
//                save: { key, dataState in
//                    self.dataState = dataState
//                }
//            ),
//            cacheDataManager: AnyCacheDataManager(
//                load: {
//                    Just(self.dataCache).eraseToAnyPublisher()
//                },
//                save: { newData in
//                    XCTFail()
//                    fatalError()
//                },
//                saveNext: { cachedData, newData in
//                    Future { promise in
//                        self.dataCache = cachedData + newData
//                        promise(.success(()))
//                    }.eraseToAnyPublisher()
//                },
//                savePrev: { cachedData, newData in
//                    Future { promise in
//                        self.dataCache = newData + cachedData
//                        promise(.success(()))
//                    }.eraseToAnyPublisher()
//                }
//            ),
//            originDataManager: AnyOriginDataManager(
//                fetch: {
//                    XCTFail()
//                    fatalError()
//                },
//                fetchNext: { nextKey in
//                    Fail(error: NoSuchElementError()).eraseToAnyPublisher()
//                },
//                fetchPrev: { prevKey in
//                    Fail(error: NoSuchElementError()).eraseToAnyPublisher()
//                }
//            ),
//            needRefresh: { value in Just(value.first?.needRefresh == true).eraseToAnyPublisher() }
//        )
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Fixed_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_FixedWithNoMoreData_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Loading_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Loading_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Loading_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Fixed_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Fixed_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_FixedWithNoMoreData_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Loading_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_FixedWithNoMoreData_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Fixed_NoCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Fixed_ValidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Fixed_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_NoCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_ValidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_FixedWithNoMoreData_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Loading_NoCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Loading_ValidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Loading_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Loading_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Fixed_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Fixed_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Fixed_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixed(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixed = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_FixedWithNoMoreData_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .fixedWithNoMoreAdditionalData = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Loading_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Loading_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Loading_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .loading(additionalRequestKey: "KEY"))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .loading = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = nil
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.validData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextAndPrev_Fixed_Error_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()))
//        dataCache = [.invalidData]
//
//        let nextRecorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: nextRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//
//        let prevRecorder = dataSelector.requestPrevData(continueWhenError: true).record()
//        _ = try wait(for: prevRecorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, let prevDataState) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//            guard case .error = prevDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//}
