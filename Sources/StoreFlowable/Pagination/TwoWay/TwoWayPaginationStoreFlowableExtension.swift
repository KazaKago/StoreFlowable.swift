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
    func create(_ param: PARAM) -> AnyTwoWayPaginationStoreFlowable<DATA> {
        AnyTwoWayPaginationStoreFlowable(StoreFlowableImpl(
            param: param,
            flowableDataStateManager: flowableDataStateManager,
            cacheDataManager: AnyCacheDataManager<DATA>(
                load: {
                    loadDataFromCache(param: param)
                },
                save: { newData in
                    saveDataToCache(newData: newData, param: param)
                },
                saveNext: { cachedData, newData in
                    saveNextDataToCache(cachedData: cachedData, newData: newData, param: param)
                },
                savePrev: { cachedData, newData in
                    savePrevDataToCache(cachedData: cachedData, newData: newData, param: param)
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin(param: param).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: result.prevKey)
                    }.eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    fetchNextDataFromOrigin(nextKey: nextKey, param: param).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchPrev: { prevKey in
                    fetchPrevDataFromOrigin(prevKey: prevKey, param: param).map { result in
                        InternalFetched(data: result.data, nextKey: nil, prevKey: result.prevKey)
                    }.eraseToAnyPublisher()
                }
            ),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData, param: param) }
        ))
    }
}
