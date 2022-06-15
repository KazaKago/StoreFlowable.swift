//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation

public extension StoreFlowable {

    static func from<PARAM, FETCHER: Fetcher>(cacher: Cacher<PARAM, DATA>, fetcher: FETCHER, param: PARAM) -> AnyStoreFlowable<DATA> where FETCHER.PARAM == PARAM, FETCHER.DATA == DATA {
        AnyStoreFlowable(StoreFlowableImpl<DATA>(
            dataStateFlowAccessor: AnyDataStateFlowAccessor(
                getFlow: {
                    cacher.getStateFlow(param: param)
                }
            ),
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    nil
                },
                saveNext: { requestKey in
                    // do nothing.
                },
                loadPrev: {
                    nil
                },
                savePrev: { requestKey in
                    // do nothing.
                }
            ),
            cacheDataManager: AnyCacheDataManager<DATA>(
                load: {
                    await cacher.loadData(param: param)
                },
                save: { newData in
                    await cacher.saveData(data: newData, param: param)
                    await cacher.saveDataCachedAt(epochSeconds: Date().timeIntervalSince1970, param: param)
                },
                saveNext: { cachedData, newData in
                    fatalError()
                },
                savePrev: { cachedData, newData in
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    let data = try await fetcher.fetch(param: param)
                    return InternalFetched(data: data, nextKey: nil, prevKey: nil)
                },
                fetchNext: { nextKey in
                    fatalError()
                },
                fetchPrev: { prevKey in
                    fatalError()
                }
            ),
            dataStateManager: AnyDataStateManager(
                load: {
                    cacher.loadState(param: param)
                },
                save: { state in
                    cacher.saveState(param: param, state: state)
                }
            ),
            needRefresh: { cachedData in
                await cacher.needRefresh(cachedData: cachedData, param: param)
            }
        ))
    }

    static func from<FETCHER: Fetcher>(cacher: Cacher<UnitHash, DATA>, fetcher: FETCHER) -> AnyStoreFlowable<DATA> where FETCHER.PARAM == UnitHash, FETCHER.DATA == DATA {
        from(cacher: cacher, fetcher: fetcher, param: UnitHash())
    }

    static func from<PARAM, FETCHER: PaginationFetcher>(cacher: PaginationCacher<PARAM, DATA>, fetcher: FETCHER, param: PARAM) -> AnyPaginationStoreFlowable<[DATA]> where FETCHER.PARAM == PARAM, FETCHER.DATA == DATA {
        AnyPaginationStoreFlowable(StoreFlowableImpl<[DATA]>(
            dataStateFlowAccessor: AnyDataStateFlowAccessor(
                getFlow: {
                    cacher.getStateFlow(param: param)
                }
            ),
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    await cacher.loadNextRequestKey(param: param)
                },
                saveNext: { requestKey in
                    await cacher.saveNextRequestKey(requestKey: requestKey, param: param)
                },
                loadPrev: {
                    nil
                },
                savePrev: { requestKey in
                    // do nothing.
                }
            ),
            cacheDataManager: AnyCacheDataManager<[DATA]>(
                load: {
                    await cacher.loadData(param: param)
                },
                save: { newData in
                    await cacher.saveData(data: newData, param: param)
                    await cacher.saveDataCachedAt(epochSeconds: Date().timeIntervalSince1970, param: param)
                },
                saveNext: { cachedData, newData in
                    await cacher.saveNextData(cachedData: cachedData, newData: newData, param: param)
                },
                savePrev: { cachedData, newData in
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<[DATA]>(
                fetch: {
                    let result = try await fetcher.fetch(param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextRequestKey, prevKey: nil)
                },
                fetchNext: { nextKey in
                    let result = try await fetcher.fetchNext(nextKey: nextKey, param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextRequestKey, prevKey: nil)
                },
                fetchPrev: { prevKey in
                    fatalError()
                }
            ),
            dataStateManager: AnyDataStateManager(
                load: {
                    cacher.loadState(param: param)
                },
                save: { state in
                    cacher.saveState(param: param, state: state)
                }
            ),
            needRefresh: { cachedData in
                await cacher.needRefresh(cachedData: cachedData, param: param)
            }
        ))
    }

    static func from<FETCHER: PaginationFetcher>(cacher: PaginationCacher<UnitHash, DATA>, fetcher: FETCHER) -> AnyPaginationStoreFlowable<[DATA]> where FETCHER.PARAM == UnitHash, FETCHER.DATA == DATA {
        from(cacher: cacher, fetcher: fetcher, param: UnitHash())
    }

    static func from<PARAM, FETCHER: TwoWayPaginationFetcher>(cacher: TwoWayPaginationCacher<PARAM, DATA>, fetcher: FETCHER, param: PARAM) -> AnyTwoWayPaginationStoreFlowable<[DATA]> where FETCHER.PARAM == PARAM, FETCHER.DATA == DATA {
        AnyTwoWayPaginationStoreFlowable(StoreFlowableImpl<[DATA]>(
            dataStateFlowAccessor: AnyDataStateFlowAccessor(
                getFlow: {
                    cacher.getStateFlow(param: param)
                }
            ),
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    await cacher.loadNextRequestKey(param: param)
                },
                saveNext: { requestKey in
                    await cacher.saveNextRequestKey(requestKey: requestKey, param: param)
                },
                loadPrev: {
                    await cacher.loadPrevRequestKey(param: param)
                },
                savePrev: { requestKey in
                    await cacher.savePrevRequestKey(requestKey: requestKey, param: param)
                }
            ),
            cacheDataManager: AnyCacheDataManager<[DATA]>(
                load: {
                    await cacher.loadData(param: param)
                },
                save: { newData in
                    await cacher.saveData(data: newData, param: param)
                    await cacher.saveDataCachedAt(epochSeconds: Date().timeIntervalSince1970, param: param)
                },
                saveNext: { cachedData, newData in
                    await cacher.saveNextData(cachedData: cachedData, newData: newData, param: param)
                },
                savePrev: { cachedData, newData in
                    await cacher.savePrevData(cachedData: cachedData, newData: newData, param: param)
                }
            ),
            originDataManager: AnyOriginDataManager<[DATA]>(
                fetch: {
                    let result = try await fetcher.fetch(param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextRequestKey, prevKey: result.prevRequestKey)
                },
                fetchNext: { nextKey in
                    let result = try await fetcher.fetchNext(nextKey: nextKey, param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextRequestKey, prevKey: nil)
                },
                fetchPrev: { prevKey in
                    let result = try await fetcher.fetchPrev(prevKey: prevKey, param: param)
                    return InternalFetched(data: result.data, nextKey: nil, prevKey: result.prevRequestKey)
                }
            ),
            dataStateManager: AnyDataStateManager(
                load: {
                    cacher.loadState(param: param)
                },
                save: { state in
                    cacher.saveState(param: param, state: state)
                }
            ),
            needRefresh: { cachedData in
                await cacher.needRefresh(cachedData: cachedData, param: param)
            }
        ))
    }

    static func from<FETCHER: TwoWayPaginationFetcher>(cacher: TwoWayPaginationCacher<UnitHash, DATA>, fetcher: FETCHER) -> AnyTwoWayPaginationStoreFlowable<[DATA]> where FETCHER.PARAM == UnitHash, FETCHER.DATA == DATA {
        from(cacher: cacher, fetcher: fetcher, param: UnitHash())
    }
}
