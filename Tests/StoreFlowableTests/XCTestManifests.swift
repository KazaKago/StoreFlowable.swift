import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StateTests.allTests),
        testCase(StateZipperTest.allTests),
        testCase(StateContentTests.allTests),
        testCase(StateContentZipperTests.allTests),
        testCase(FlowStateMapperTests.allTests),
        testCase(FlowStateZipperTests.allTests),
        testCase(DataSelectorTest.allTests),
        testCase(StoreFlowableTests.allTests),
    ]
}
#endif
