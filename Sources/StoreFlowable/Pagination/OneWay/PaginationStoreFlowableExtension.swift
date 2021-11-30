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
        AnyPaginationStoreFlowable(StoreFlowableImpl(
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
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin(param: param).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    fetchNextDataFromOrigin(nextKey: nextKey, param: param).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchPrev: { prevKey in
                    fatalError()
                }
            ),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData, param: param) }
        ))
    }
}
