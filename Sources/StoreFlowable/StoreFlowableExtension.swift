//
//  StoreFlowableExtension.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation

public extension StoreFlowableFactory {

    /**
     * Create `StoreFlowable` class from `StoreFlowableFactory`.
     *
     * - returns: Created StateFlowable.
     */
    func create(_ param: PARAM) -> AnyStoreFlowable<DATA> {
        AnyStoreFlowable(StoreFlowableImpl<DATA>(
            dataStateFlowAccessor: AnyDataStateFlowAccessor(
                getFlow: {
                    flowableDataStateManager.getFlow(param: param)
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
                    await loadDataFromCache(param: param)
                },
                save: { newData in
                    await saveDataToCache(newData: newData, param: param)
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
                    let data = try await fetchDataFromOrigin(param: param)
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
