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
    func create() -> AnyPaginationStoreFlowable<DATA> {
        AnyPaginationStoreFlowable(StoreFlowableImpl(
            param: param,
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
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin().map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    fetchNextDataFromOrigin(nextKey: nextKey).map { result in
                        InternalFetched(data: result.data, nextKey: result.nextKey, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchPrev: { prevKey in
                    fatalError()
                }
            ),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData) }
        ))
    }
}
