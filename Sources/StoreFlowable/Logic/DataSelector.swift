//
//  DataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

struct DataSelector<DATA> {

    private let requestKeyManager: RequestKeyManager
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let originDataManager: AnyOriginDataManager<DATA>
    private let dataStateManager: DataStateManager
    private let needRefresh: (_ cachedData: DATA) async -> Bool

    init(requestKeyManager: RequestKeyManager, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, dataStateManager: DataStateManager, needRefresh: @escaping (_ data: DATA) async -> Bool) {
        self.requestKeyManager = requestKeyManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.dataStateManager = dataStateManager
        self.needRefresh = needRefresh
    }

    func loadValidCacheOrNil() async -> DATA? {
        guard let data = await cacheDataManager.load() else { return nil }
        return !(await needRefresh(data)) ? data : nil
    }

    func update(newData: DATA?, nextKey: String?, prevKey: String?) async {
        await cacheDataManager.save(newData: newData)
        if let nextKey = nextKey { await requestKeyManager.saveNext(requestKey: nextKey) }
        if let prevKey = prevKey { await requestKeyManager.savePrev(requestKey: prevKey) }
        dataStateManager.save(state: .fixed(nextDataState: .fixed, prevDataState: .fixed))
    }

    func clear() async {
        await cacheDataManager.save(newData: nil)
        await requestKeyManager.saveNext(requestKey: nil)
        await requestKeyManager.savePrev(requestKey: nil)
        dataStateManager.save(state: .fixed(nextDataState: .fixed, prevDataState: .fixed))
    }

    func validate() async {
        await doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, requestType: .refresh)
    }

    func validateAsync() async {
        await doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false, requestType: .refresh)
    }

    func refresh(clearCacheBeforeFetching: Bool) async {
        await doStateAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, requestType: .refresh)
    }

    func refreshAsync(clearCacheBeforeFetching: Bool) async {
        await doStateAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false, requestType: .refresh)
    }

    func requestNextData(continueWhenError: Bool) async {
        await doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: false, continueWhenError: continueWhenError, awaitFetching: true, requestType: .next)
    }

    func requestPrevData(continueWhenError: Bool) async {
        await doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: false, continueWhenError: continueWhenError, awaitFetching: true, requestType: .prev)
    }

    private func doStateAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, continueWhenError: Bool, awaitFetching: Bool, requestType: RequestType) async {
        switch dataStateManager.load() {
        case .fixed(let nextDataState, let prevDataState):
            switch requestType {
            case .refresh:
                if case .loading = nextDataState, case .loading = prevDataState {} else {
                    await doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .refresh)
                }
            case .next:
                let nextKey = await requestKeyManager.loadNext()
                if !nextKey.isNilOrEmpty() {
                    switch nextDataState {
                    case .fixed:
                        await doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .next(requestKey: nextKey!))
                    case .loading:
                        break
                    case .error(_):
                        if continueWhenError { await doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .next(requestKey: nextKey!)) }
                    }
                }
            case .prev:
                let prevKey = await requestKeyManager.loadPrev()
                if !prevKey.isNilOrEmpty() {
                    switch prevDataState {
                    case .fixed:
                        await doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .prev(requestKey: prevKey!))
                    case .loading:
                        break
                    case .error(_):
                        if continueWhenError { await doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .prev(requestKey: prevKey!)) }
                    }
                }
            }
        case .loading:
            break
        case .error:
            switch requestType {
            case .refresh:
                if continueWhenError { await doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .refresh) }
            case .next, .prev:
                dataStateManager.save(state: .error(rawError: AdditionalRequestOnErrorStateException()))
            }
        }
    }

    private func doDataAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, requestType: KeyedRequestType) async {
        let cachedData = await cacheDataManager.load()
        switch requestType {
        case .refresh:
            if cachedData == nil || forceRefresh {
                await prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: requestType)
            } else {
                let needRefresh = await needRefresh(cachedData!)
                if needRefresh {
                    await prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: requestType)
                }
            }
        case .next(_), .prev(_):
            if let _ = cachedData {
                await prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: requestType)
            } else {
                dataStateManager.save(state: .error(rawError: AdditionalRequestOnNilException()))
            }
        }
    }

    private func prepareFetch(clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, requestType: KeyedRequestType) async {
        if clearCacheBeforeFetching { await cacheDataManager.save(newData: nil) }
        let state = dataStateManager.load()
        switch requestType {
        case .refresh:
            dataStateManager.save(state: .loading())
        case .next(_):
            dataStateManager.save(state: .fixed(nextDataState: .loading, prevDataState: state.prevDataState()))
        case .prev(_):
            dataStateManager.save(state: .fixed(nextDataState: state.nextDataState(), prevDataState: .loading))
        }
        if awaitFetching {
            await fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails, requestType: requestType)
        } else {
            Task { await fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails, requestType: requestType) }
        }
    }

    private func fetchNewData(clearCacheWhenFetchFails: Bool, requestType: KeyedRequestType) async {
        do {
            switch requestType {
            case .refresh:
                let result = try await originDataManager.fetch()
                await cacheDataManager.save(newData: result.data)
                await requestKeyManager.saveNext(requestKey: result.nextKey)
                await requestKeyManager.savePrev(requestKey: result.prevKey)
                dataStateManager.save(state: .fixed(nextDataState: .fixed, prevDataState: .fixed))
            case .next(let requestKey):
                let result = try await originDataManager.fetchNext(nextKey: requestKey)
                guard let cachedData = await cacheDataManager.load() else { throw AdditionalRequestOnNilException() }
                await cacheDataManager.saveNext(cachedData: cachedData, newData: result.data)
                await requestKeyManager.saveNext(requestKey: result.nextKey)
                let state = dataStateManager.load()
                dataStateManager.save(state: .fixed(nextDataState: .fixed, prevDataState: state.prevDataState()))
            case .prev(let requestKey):
                let result = try await originDataManager.fetchPrev(prevKey: requestKey)
                guard let cachedData = await cacheDataManager.load() else { throw AdditionalRequestOnNilException() }
                await cacheDataManager.savePrev(cachedData: cachedData, newData: result.data)
                await requestKeyManager.savePrev(requestKey: result.prevKey)
                let state = dataStateManager.load()
                dataStateManager.save(state: .fixed(nextDataState: state.nextDataState(), prevDataState: .fixed))
            }
        } catch {
            if clearCacheWhenFetchFails { await cacheDataManager.save(newData: nil) }
            let state = dataStateManager.load()
            switch (requestType) {
            case .refresh:
                dataStateManager.save(state: .error(rawError: error))
            case .next:
                dataStateManager.save(state: .fixed(nextDataState: .error(rawError: error), prevDataState: state.prevDataState()))
            case .prev:
                dataStateManager.save(state: .fixed(nextDataState: state.nextDataState(), prevDataState: .error(rawError: error)))
            }
        }
    }
}
