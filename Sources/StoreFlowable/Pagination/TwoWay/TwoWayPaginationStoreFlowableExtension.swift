//
//  TwoWayPaginationStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

public extension TwoWayPaginationStoreFlowableFactory {

    /**
     * Create `PaginationStoreFlowable` class from `PaginationStoreFlowableFactory`.
     *
     * - returns: Created PaginationStoreFlowable.
     */
    func create(_ param: PARAM) -> AnyTwoWayPaginationStoreFlowable<DATA> {
        AnyTwoWayPaginationStoreFlowable(StoreFlowableImpl(
            dataStateFlowAccessor: AnyDataStateFlowAccessor(
                getFlow: {
                    flowableDataStateManager.getFlow(param: param)
                }
            ),
            requestKeyManager: AnyRequestKeyManager(
                loadNext: {
                    flowableDataStateManager.loadNext(param: param)
                },
                saveNext: { requestKey in
                    flowableDataStateManager.saveNext(param: param, requestKey: requestKey)
                },
                loadPrev: {
                    flowableDataStateManager.loadPrev(param: param)
                },
                savePrev: { requestKey in
                    flowableDataStateManager.savePrev(param: param, requestKey: requestKey)
                }
            ),
            cacheDataManager: AnyCacheDataManager<DATA>(
                load: {
                    await loadDataFromCache(param: param)
                },
                save: { newData in
                    await saveDataToCache(newData: newData, param: param)
                },
                saveNext: { cachedData, newData in
                    await saveNextDataToCache(cachedData: cachedData, newData: newData, param: param)
                },
                savePrev: { cachedData, newData in
                    await savePrevDataToCache(cachedData: cachedData, newData: newData, param: param)
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    let result = try await fetchDataFromOrigin(param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: result.prevKey)
                },
                fetchNext: { nextKey in
                    let result = try await fetchNextDataFromOrigin(nextKey: nextKey, param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                },
                fetchPrev: { prevKey in
                    let result = try await fetchPrevDataFromOrigin(prevKey: prevKey, param: param)
                    return InternalFetched(data: result.data, nextKey: nil, prevKey: result.prevKey)
                }
            ),
            dataStateManager: AnyDataStateManager(
                load: {
                    flowableDataStateManager.load(param: param)
                },
                save: { state in
                    flowableDataStateManager.save(param: param, state: state)
                }
            ),
            needRefresh: { cachedData in
                await needRefresh(cachedData: cachedData, param: param)
            }
        ))
    }
}
