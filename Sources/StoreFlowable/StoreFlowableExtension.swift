//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine

public extension StoreFlowableFactory {

    /**
     * Create `StoreFlowable` class from `StoreFlowableFactory`.
     *
     * - returns: Created StateFlowable.
     */
    func create() -> AnyStoreFlowable<DATA> {
        AnyStoreFlowable(StoreFlowableImpl(
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
                    fatalError()
                },
                savePrev: { cachedData, newData in
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin().map { data in
                        InternalFetched(data: data, nextKey: nil, prevKey: nil)
                    }.eraseToAnyPublisher()
                },
                fetchNext: { nextKey in
                    fatalError()
                },
                fetchPrev: { prevKey in
                    fatalError()
                }
            ),
            needRefresh: { cachedData in needRefresh(cachedData: cachedData) }
        ))
    }
}
