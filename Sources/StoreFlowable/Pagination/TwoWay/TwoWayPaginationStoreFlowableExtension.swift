//
//  TwoWayPaginationStoreFlowableFactory.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/20.
//

import Foundation
import Combine

public extension TwoWayPaginationStoreFlowableFactory {

    /**
     * Create `PaginationStoreFlowable` class from `PaginationStoreFlowableFactory`.
     *
     * - returns: Created PaginationStoreFlowable.
     */
    func create() -> AnyTwoWayPaginationStoreFlowable<KEY, DATA> {
        AnyTwoWayPaginationStoreFlowable(StoreFlowableImpl(
            key: key,
            flowableDataStateManager: flowableDataStateManager,
            cacheDataManager: AnyCacheDataManager<DATA>(
                load: {
                    loadDataFromCache()
                },
                save: { newData in
                    saveDataToCache(newData: newData)
                },
                saveNext: { cachedData, newData in
                    saveNextDataToCache(cachedData: cachedData, newData: newData)
                },
                savePrev: { cachedData, newData in
                    savePrevDataToCache(cachedData: cachedData, newData: newData)
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin().map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: result.prevKey)
                    }.eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    fetchNextDataFromOrigin(nextKey: nextKey).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchPrev: { prevKey in
                    fetchPrevDataFromOrigin(prevKey: prevKey).map { result in
                        InternalFetched(data: result.data, nextKey: nil, prevKey: result.prevKey)
                    }.eraseToAnyPublisher()
                }
            ),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData) }
        ))
    }
}
