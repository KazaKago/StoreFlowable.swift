//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class DataSelectorLoadTests: XCTestCase {
//
//    private enum TestData: Equatable {
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
//    private var dataSelector: DataSelector<UnitHash, TestData>!
//    private var dataState: DataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//    private var dataCache: TestData? = nil
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
//                    Future { promise in
//                        self.dataCache = newData
//                        promise(.success(()))
//                    }.eraseToAnyPublisher()
//                },
//                saveNext: { cachedData, newData in
//                    XCTFail()
//                    fatalError()
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
//                    XCTFail()
//                    fatalError()
//                },
//                fetchPrev: { prevKey in
//                    XCTFail()
//                    fatalError()
//                }
//            ),
//            needRefresh: { value in Just(value.needRefresh).eraseToAnyPublisher() }
//        )
//    }
//
//    func test_Load_NoCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = nil
//
//        let recorder = dataSelector.loadValidCacheOrNil().record()
//        let data = try wait(for: recorder.next(), timeout: 1)
//        XCTAssertEqual(data, nil)
//    }
//
//    func test_Load_ValidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = .validData
//
//        let recorder = dataSelector.loadValidCacheOrNil().record()
//        let data = try wait(for: recorder.next(), timeout: 1)
//        guard case .validData = data else { return XCTFail() }
//    }
//
//    func test_Load_InvalidCache() throws {
//        dataState = .fixed(nextDataState: .fixedWithNoMoreAdditionalData, prevDataState: .fixedWithNoMoreAdditionalData)
//        dataCache = .invalidData
//
//        let recorder = dataSelector.loadValidCacheOrNil().record()
//        let data = try wait(for: recorder.next(), timeout: 1)
//        XCTAssertEqual(data, nil)
//    }
//}
