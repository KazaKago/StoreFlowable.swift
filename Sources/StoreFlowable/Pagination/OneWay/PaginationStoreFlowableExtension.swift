//
//  PaginationStoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation

public extension PaginationStoreFlowableFactory {

    /**
     * Create `PaginationStoreFlowable` class from `PaginationStoreFlowableFactory`.
     *
     * - returns: Created PaginationStoreFlowable.
     */
    func create(_ param: PARAM) -> AnyPaginationStoreFlowable<DATA> {
        AnyPaginationStoreFlowable(StoreFlowableImpl<DATA>(
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
                    nil
                },
                savePrev: { requestKey in
                    // do nothing.
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
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    let result = try await fetchDataFromOrigin(param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                },
                fetchNext: { nextKey in
                    let result = try await fetchNextDataFromOrigin(nextKey: nextKey, param: param)
                    return InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                },
                fetchPrev: { prevKey in
                    fatalError()
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
