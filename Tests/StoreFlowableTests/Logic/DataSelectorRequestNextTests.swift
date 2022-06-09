//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class DataSelectorRequestNextTests: XCTestCase {
//
//    private enum TestData: Equatable {
//        case validData
//        case invalidData
//        case fetchedData
//        case fetchedNextData
//
//        var needRefresh: Bool {
//            switch self {
//            case .validData: return false
//            case .invalidData: return true
//            case .fetchedData: return false
//            case .fetchedNextData: return false
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
//                    XCTFail()
//                    fatalError()
//                }
//            ),
//            originDataManager: AnyOriginDataManager(
//                fetch: {
//                    XCTFail()
//                    fatalError()
//                },
//                fetchNext: { nextKey in
//                    Just(InternalFetched(data: [.fetchedNextData], nextKey: "KEY", prevKey: nil))
//                        .setFailureType(to: Error.self)
//                        .eraseToAnyPublisher()
//                },
//                fetchPrev: { prevKey in
//                    XCTFail()
//                    fatalError()
//                }
//            ),
//            needRefresh: { value in Just(value.first?.needRefresh == true).eraseToAnyPublisher() }
//        )
//    }
//
//    func test_RequestNextData_Fixed_Fixed_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Fixed_Fixed_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixed = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData, .fetchedNextData])
//    }
//
//    func test_RequestNextData_Fixed_Fixed_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixed(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixed = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData, .fetchedNextData])
//    }
//
//    func test_RequestNextData_Fixed_FixedWithNoMoreData_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Fixed_FixedWithNoMoreData_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextData_Fixed_FixedWithNoMoreData_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixedWithNoMoreAdditionalData = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextData_Fixed_Loading_NoCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Fixed_Loading_ValidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextData_Fixed_Loading_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .loading(additionalRequestKey: "KEY"), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .loading = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextData_Fixed_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnNilException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Fixed_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixed = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData, .fetchedNextData])
//    }
//
//    func test_RequestNextData_Fixed_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .fixed = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData, .fetchedNextData])
//    }
//
//    func test_RequestNextData_Loading_NoCache() throws {
//        dataState = .loading
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        guard case .loading = self.dataState else { return XCTFail() }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Loading_ValidCache() throws {
//        dataState = .loading
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        guard case .loading = self.dataState else { return XCTFail() }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextData_Loading_InvalidCache() throws {
//        dataState = .loading
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        guard case .loading = self.dataState else { return XCTFail() }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextData_Error_NoCache() throws {
//        dataState = .error(rawError: NoSuchElementError())
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_Error_ValidCache() throws {
//        dataState = .error(rawError: NoSuchElementError())
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextData_Error_InvalidCache() throws {
//        dataState = .error(rawError: NoSuchElementError())
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: true).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .error(let rawError) = self.dataState {
//            XCTAssert(rawError is AdditionalRequestOnErrorStateException)
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//
//    func test_RequestNextData_NonContinueWhenError_Fixed_Error_NoCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.requestNextData(continueWhenError: false).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//
//    func test_RequestNextData_NonContinueWhenError_Fixed_Error_ValidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.validData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: false).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.validData])
//    }
//
//    func test_RequestNextData_NonContinueWhenError_Fixed_Error_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .error(additionalRequestKey: "KEY", rawError: NoSuchElementError()), prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = [.invalidData]
//
//        let recorder = dataSelector.requestNextData(continueWhenError: false).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        if case .fixed(let nextDataState, _) = self.dataState {
//            guard case .error = nextDataState else { return XCTFail() }
//        } else {
//            XCTFail()
//        }
//        XCTAssertEqual(self.dataCache, [.invalidData])
//    }
//}
