//
//  StoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation

struct StoreFlowableImpl<DATA>: StoreFlowable, PaginationStoreFlowable, TwoWayPaginationStoreFlowable {

    typealias DATA = DATA

    private let dataStateFlowAccessor: DataStateFlowAccessor
    private let requestKeyManager: RequestKeyManager
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let dataSelector: DataSelector<DATA>

    init(dataStateFlowAccessor: DataStateFlowAccessor, requestKeyManager: RequestKeyManager, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, dataStateManager: DataStateManager, needRefresh: @escaping (_ cachedData: DATA) async -> Bool) {
        self.dataStateFlowAccessor = dataStateFlowAccessor
        self.requestKeyManager = requestKeyManager
        self.cacheDataManager = cacheDataManager
        self.dataSelector = DataSelector(
            requestKeyManager: requestKeyManager,
            cacheDataManager: cacheDataManager,
            originDataManager: originDataManager,
            dataStateManager: dataStateManager,
            needRefresh: needRefresh
        )
    }

    func publish(forceRefresh: Bool) -> LoadingStateSequence<DATA> {
        AsyncStream<Void> { continuation in
            Task {
                if forceRefresh {
                    await dataSelector.refreshAsync(clearCacheBeforeFetching: true)
                } else {
                    await dataSelector.validateAsync()
                }
                continuation.yield(())
                continuation.finish()
            }
        }
        .flatMap { _ in
            dataStateFlowAccessor.getFlow()
        }
        .map { dataState in
            await dataState.toLoadingState(
                content: await cacheDataManager.load(),
                canNextRequest: requestKeyManager.loadNext() != nil,
                canPrevRequest: requestKeyManager.loadPrev() != nil
            )
        }
        .eraseToAnyAsyncSequence()
    }

    func getData(from: GettingFrom) async -> DATA? {
        try? await requireData(from: from)
    }

    func requireData(from: GettingFrom) async throws -> DATA {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                switch from {
                case .both:
                    await dataSelector.validate()
                case .origin:
                    await dataSelector.refresh(clearCacheBeforeFetching: true)
                case .cache:
                    break
                }
                for try await dataState in dataStateFlowAccessor.getFlow() {
                    switch dataState {
                    case .fixed:
                        let data = await dataSelector.loadValidCacheOrNil()
                        if let data = data {
                            continuation.resume(returning: data)
                            return
                        } else {
                            continuation.resume(throwing: NoSuchElementError())
                            return
                        }
                    case .loading:
                        break
                    case .error(_, _, let rawError):
                        let data = await dataSelector.loadValidCacheOrNil()
                        if let data = data {
                            continuation.resume(returning: data)
                            return
                        } else {
                            continuation.resume(throwing: rawError)
                            return
                        }
                    }
                }
            }
        }
    }

    func validate() async {
        await dataSelector.validate()
    }

    func refresh() async {
        await dataSelector.refresh(clearCacheBeforeFetching: false)
    }

    func requestNextData(continueWhenError: Bool) async {
        await dataSelector.requestNextData(continueWhenError: continueWhenError)
    }

    func requestPrevData(continueWhenError: Bool) async {
        await dataSelector.requestPrevData(continueWhenError: continueWhenError)
    }

    func update(newData: DATA?) async {
        await dataSelector.update(newData: newData, nextKey: nil, prevKey: nil)
    }

    func update(newData: DATA?, nextKey: String?) async {
        await dataSelector.update(newData: newData, nextKey: nextKey, prevKey: nil)
    }

    func update(newData: DATA?, nextKey: String?, prevKey: String?) async {
        await dataSelector.update(newData: newData, nextKey: nextKey, prevKey: prevKey)
    }
    
    func clear() async {
        await dataSelector.clear()
    }
}
