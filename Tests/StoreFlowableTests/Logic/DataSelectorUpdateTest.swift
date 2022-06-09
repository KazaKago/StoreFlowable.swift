//import XCTest
//import Combine
//import CombineExpectations
//@testable import StoreFlowable
//
//final class DataSelectorUpdateTests: XCTestCase {
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
//                    Just(InternalFetched(data: .fetchedData, nextKey: nil, prevKey: nil))
//                        .setFailureType(to: Error.self)
//                        .eraseToAnyPublisher()
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
//    func test_Update_Data() throws {
//        dataState = .loading
//        dataCache = nil
//
//        let recorder = dataSelector.update(newData: .fetchedData, nextKey: nil, prevKey: nil).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        guard case .fixed = self.dataState else { return XCTFail() }
//        XCTAssertEqual(self.dataCache, .fetchedData)
//    }
//
//    func test_Update_Nil() throws {
//        dataState = .error(rawError: NoSuchElementError())
//        dataCache = .invalidData
//
//        let recorder = dataSelector.update(newData: nil, nextKey: nil, prevKey: nil).record()
//        _ = try wait(for: recorder.elements, timeout: 1)
//        guard case .fixed = self.dataState else { return XCTFail() }
//        XCTAssertEqual(self.dataCache, nil)
//    }
//}
