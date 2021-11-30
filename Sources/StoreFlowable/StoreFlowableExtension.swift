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
    func create(_ param: PARAM) -> AnyStoreFlowable<DATA> {
        AnyStoreFlowable(StoreFlowableImpl(
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
                    fatalError()
                },
                savePrev: { cachedData, newData in
                    fatalError()
                }
            ),
            originDataManager: AnyOriginDataManager<DATA>(
                fetch: {
                    fetchDataFromOrigin(param: param).map { data in
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
            needRefresh: { cachedData in needRefresh(cachedData: cachedData, param: param) }
        ))
    }
}
