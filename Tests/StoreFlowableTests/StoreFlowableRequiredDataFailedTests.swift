import XCTest
@testable import StoreFlowable

final class StoreFlowableRequiredDataFailedTests: XCTestCase {

    private enum TestData {
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

    private class TestCacher: Cacher<UnitHash, TestData> {

        private var cache: TestData?

        convenience init(cache: TestData?) {
            self.init()
            self.cache = cache
        }

        override func loadData(param: UnitHash) async -> TestData? {
            cache
        }
        override func saveData(data: TestData?, param: UnitHash) async {
            cache = data
        }

        override func needRefresh(cachedData: TestData, param: UnitHash) async -> Bool {
            cachedData.needRefresh
        }
    }

    private class TestFetcher: Fetcher {

        typealias PARAM = UnitHash
        typealias DATA = TestData

        func fetch(param: PARAM) async throws -> TestData {
            throw NoSuchElementError()
        }
    }

    func test_RequiredData_Both_NoCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: nil), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .both)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Both_ValidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .validData), fetcher: TestFetcher())
        let data = try await storeFlowable.requireData(from: .both)
        guard case .validData = data else { return XCTFail() }
    }

    func test_RequiredData_Both_InvalidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .invalidData), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .both)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Cache_NoCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: nil), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .cache)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Cache_ValidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .validData), fetcher: TestFetcher())
        let data = try await storeFlowable.requireData(from: .cache)
        guard case .validData = data else { return XCTFail() }
    }

    func test_RequiredData_Cache_InvalidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .invalidData), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .cache)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Origin_NoCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: nil), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .origin)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Origin_ValidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .validData), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .origin)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }

    func test_RequiredData_Origin_InvalidCache() async throws {
        let storeFlowable = AnyStoreFlowable.from(cacher: TestCacher(cache: .invalidData), fetcher: TestFetcher())
        await XCTAssertThrowsError(try await storeFlowable.requireData(from: .origin)) { error in
            XCTAssert(error is NoSuchElementError)
        }
    }
}
