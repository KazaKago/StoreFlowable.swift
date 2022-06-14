import XCTest
@testable import StoreFlowable

final class LoadingStateZipperTest: XCTestCase {

    private let loading: LoadingState<Int> = .loading(content: nil)
    private let loadingWithData: LoadingState<Int> = .loading(content: 70)
    private let completed: LoadingState<Int> = .completed(content: 30, next: .fixed(canRequestAdditionalData: true), prev: .fixed(canRequestAdditionalData: true))
    private let error: LoadingState<Int> = .error(rawError: NoSuchElementError())

    func test_Zip_Loading_Loading() {
        let zippedState: LoadingState<Int> = loading.zip(loading) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, nil)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_Loading_LoadingWithData() {
        let zippedState: LoadingState<Int> = loading.zip(loadingWithData) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, nil)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_Loading_Completed() {
        let zippedState: LoadingState<Int> = loading.zip(completed) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, nil)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTFail()
            }
        )
    }

    func test_Zip_Loading_Error() {
        let zippedState: LoadingState<Int> = loading.zip(error) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_LoadingWithData_Loading() {
        let zippedState: LoadingState<Int> = loadingWithData.zip(loading) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, nil)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_LoadingWithData_LoadingWithData() {
        let zippedState: LoadingState<Int> = loadingWithData.zip(loadingWithData) { value1, value2 in
            XCTAssertEqual(value1, 70)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, 140)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_LoadingWithData_Completed() {
        let zippedState: LoadingState<Int> = loadingWithData.zip(completed) { value1, value2 in
            XCTAssertEqual(value1, 70)
            XCTAssertEqual(value2, 30)
            return value1 + value2
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, 100)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_LoadingWithData_Error() {
        let zippedState: LoadingState<Int> = loadingWithData.zip(error) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_Completed_Loading() {
        let zippedState: LoadingState<Int> = completed.zip(loading) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, nil)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_Completed_LoadingWithData() {
        let zippedState: LoadingState<Int> = completed.zip(loadingWithData) { value1, value2 in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 70)
            return value1 + value2
        }
        zippedState.doAction(
            onLoading: { content in
                XCTAssertEqual(content, 100)
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_Completed_Completed() {
        let zippedState: LoadingState<Int> = completed.zip(completed) { value1, value2 in
            XCTAssertEqual(value1, 30)
            XCTAssertEqual(value2, 30)
            return value1 + value2
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { content, _, _ in
                XCTAssertEqual(content, 60)
            },
            onError: { _ in
                XCTFail()
            }
        )
    }

    func test_Zip_Completed_Error() {
        let zippedState: LoadingState<Int> = completed.zip(error) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_Error_Loading() {
        let zippedState: LoadingState<Int> = error.zip(loading) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_Error_LoadingWithData() {
        let zippedState: LoadingState<Int> = error.zip(loadingWithData) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_Error_Completed() {
        let zippedState: LoadingState<Int> = error.zip(completed) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }

    func test_Zip_Error_Error() {
        let zippedState: LoadingState<Int> = error.zip(error) { _, _ in
            XCTFail()
            fatalError()
        }
        zippedState.doAction(
            onLoading: { _ in
                XCTFail()
            },
            onCompleted: { _, _, _ in
                XCTFail()
            },
            onError: { error in
                XCTAssert(error is NoSuchElementError)
            }
        )
    }
}
