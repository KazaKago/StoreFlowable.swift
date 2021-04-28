#if !canImport(ObjectiveC)
import XCTest

extension DataSelectorTest {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DataSelectorTest = [
        ("testDoActionWithErrorStateNoCache", testDoActionWithErrorStateNoCache),
        ("testDoActionWithErrorStateValidCache", testDoActionWithErrorStateValidCache),
        ("testDoActionWithFixedStateInvalidData", testDoActionWithFixedStateInvalidData),
        ("testDoActionWithFixedStateNoCache", testDoActionWithFixedStateNoCache),
        ("testDoActionWithFixedStateValidCache", testDoActionWithFixedStateValidCache),
        ("testDoActionWithLoadingStateNoCache", testDoActionWithLoadingStateNoCache),
        ("testDoActionWithLoadingStateValidCache", testDoActionWithLoadingStateValidCache),
    ]
}

extension FlowStateMapperTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FlowStateMapperTests = [
        ("testMapContent", testMapContent),
    ]
}

extension FlowStateZipperTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FlowStateZipperTests = [
        ("testZipWithFixedError", testZipWithFixedError),
        ("testZipWithFixedFixed", testZipWithFixedFixed),
        ("testZipWithFixedLoading", testZipWithFixedLoading),
        ("testZipWithLoadingError", testZipWithLoadingError),
    ]
}

extension FlowableDataStateManagerTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FlowableDataStateManagerTests = [
        ("testFlowDifferentKeyEvent", testFlowDifferentKeyEvent),
        ("testFlowSameKeyEvent", testFlowSameKeyEvent),
    ]
}

extension StateContentTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StateContentTests = [
        ("testDoActionWithExist", testDoActionWithExist),
        ("testDoActionWithNotExist", testDoActionWithNotExist),
        ("testRawContent", testRawContent),
        ("testWrap", testWrap),
    ]
}

extension StateContentZipperTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StateContentZipperTests = [
        ("testZipWithExistExist", testZipWithExistExist),
        ("testZipWithExistNotExist", testZipWithExistNotExist),
        ("testZipWithNotExistNotExist", testZipWithNotExistNotExist),
    ]
}

extension StateTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StateTests = [
        ("testContent", testContent),
        ("testDoActionWithError", testDoActionWithError),
        ("testDoActionWithFixed", testDoActionWithFixed),
        ("testDoActionWithLoading", testDoActionWithLoading),
    ]
}

extension StateZipperTest {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StateZipperTest = [
        ("testZipWithFixedError", testZipWithFixedError),
        ("testZipWithFixedFixedNotExist", testZipWithFixedFixedNotExist),
        ("testZipWithFixedLoading", testZipWithFixedLoading),
        ("testZipWithLoadingError", testZipWithLoadingError),
    ]
}

extension StoreFlowableTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StoreFlowableTests = [
        ("testFlowFailedWithInvalidCache", testFlowFailedWithInvalidCache),
        ("testFlowFailedWithNoCache", testFlowFailedWithNoCache),
        ("testFlowFailedWithValidCache", testFlowFailedWithValidCache),
        ("testFlowWithInvalidCache", testFlowWithInvalidCache),
        ("testFlowWithNoCache", testFlowWithNoCache),
        ("testFlowWithValidCache", testFlowWithValidCache),
        ("testGetFailedFromCacheWithInvalidCache", testGetFailedFromCacheWithInvalidCache),
        ("testGetFailedFromCacheWithNoCache", testGetFailedFromCacheWithNoCache),
        ("testGetFailedFromCacheWithValidCache", testGetFailedFromCacheWithValidCache),
        ("testGetFailedFromMixWithInvalidCache", testGetFailedFromMixWithInvalidCache),
        ("testGetFailedFromMixWithNoCache", testGetFailedFromMixWithNoCache),
        ("testGetFailedFromMixWithValidCache", testGetFailedFromMixWithValidCache),
        ("testGetFailedFromOriginWithInvalidCache", testGetFailedFromOriginWithInvalidCache),
        ("testGetFailedFromOriginWithNoCache", testGetFailedFromOriginWithNoCache),
        ("testGetFailedFromOriginWithValidCache", testGetFailedFromOriginWithValidCache),
        ("testGetFromCacheWithInvalidCache", testGetFromCacheWithInvalidCache),
        ("testGetFromCacheWithNoCache", testGetFromCacheWithNoCache),
        ("testGetFromCacheWithValidCache", testGetFromCacheWithValidCache),
        ("testGetFromMixWithInvalidCache", testGetFromMixWithInvalidCache),
        ("testGetFromMixWithNoCache", testGetFromMixWithNoCache),
        ("testGetFromMixWithValidCache", testGetFromMixWithValidCache),
        ("testGetFromOriginWithInvalidCache", testGetFromOriginWithInvalidCache),
        ("testGetFromOriginWithNoCache", testGetFromOriginWithNoCache),
        ("testGetFromOriginWithValidCache", testGetFromOriginWithValidCache),
        ("testRefresh", testRefresh),
        ("testUpdateData", testUpdateData),
        ("testUpdateNil", testUpdateNil),
        ("testValidateWithInvalidData", testValidateWithInvalidData),
        ("testValidateWithNoCache", testValidateWithNoCache),
        ("testValidateWithValidData", testValidateWithValidData),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DataSelectorTest.__allTests__DataSelectorTest),
        testCase(FlowStateMapperTests.__allTests__FlowStateMapperTests),
        testCase(FlowStateZipperTests.__allTests__FlowStateZipperTests),
        testCase(FlowableDataStateManagerTests.__allTests__FlowableDataStateManagerTests),
        testCase(StateContentTests.__allTests__StateContentTests),
        testCase(StateContentZipperTests.__allTests__StateContentZipperTests),
        testCase(StateTests.__allTests__StateTests),
        testCase(StateZipperTest.__allTests__StateZipperTest),
        testCase(StoreFlowableTests.__allTests__StoreFlowableTests),
    ]
}
#endif
