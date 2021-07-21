//
//  DataSelector.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation
import Combine
import CombineAsync

struct DataSelector<KEY, DATA> {

    private let key: KEY
    private let dataStateManager: AnyDataStateManager<KEY>
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let originDataManager: AnyOriginDataManager<DATA>
    private let needRefresh: (_ cachedData: DATA) -> AnyPublisher<Bool, Never>

    init(key: KEY, dataStateManager: AnyDataStateManager<KEY>, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, needRefresh: @escaping (_ data: DATA) -> AnyPublisher<Bool, Never>) {
        self.key = key
        self.dataStateManager = dataStateManager
        self.cacheDataManager = cacheDataManager
        self.originDataManager = originDataManager
        self.needRefresh = needRefresh
    }

    func loadValidCacheOrNil() -> AnyPublisher<DATA?, Never> {
        async { yield in
            if let data = try `await`(cacheDataManager.load()) {
                if !(try! `await`(needRefresh(data))) {
                    yield(data)
                } else {
                    yield(nil)
                }
            } else {
                yield(nil)
            }
        }
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }

    func update(newData: DATA?, nextKey: String?, prevKey: String?) -> AnyPublisher<Void, Never> {
        async { _ in
            try `await`(cacheDataManager.save(newData: newData))
            let nextDataState: AdditionalDataState
            if let nextKey = nextKey {
                nextDataState = .fixed(additionalRequestKey: nextKey)
            } else {
                let state = dataStateManager.load(key: key)
                if let nextKey = state.nextKeyOrNil() {
                    nextDataState = .fixed(additionalRequestKey: nextKey)
                } else {
                    nextDataState = .fixedWithNoMoreAdditionalData
                }
            }
            let prevDataState: AdditionalDataState
            if let prevKey = prevKey {
                prevDataState = .fixed(additionalRequestKey: prevKey)
            } else {
                let state = dataStateManager.load(key: key)
                if let prevKey = state.prevKeyOrNil() {
                    prevDataState = .fixed(additionalRequestKey: prevKey)
                } else {
                    prevDataState = .fixedWithNoMoreAdditionalData
                }
            }
            dataStateManager.save(key: key, state: .fixed(nextDataState: nextDataState, prevDataState: prevDataState))
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    func validate() -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, requestType: .refresh)
    }

    func validateAsync() -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: false, clearCacheBeforeFetching: true, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false, requestType: .refresh)
    }

    func refresh(clearCacheBeforeFetching: Bool) -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: true, requestType: .refresh)
    }

    func refreshAsync(clearCacheBeforeFetching: Bool) -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: true, continueWhenError: true, awaitFetching: false, requestType: .refresh)
    }

    func requestNextData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: false, continueWhenError: continueWhenError, awaitFetching: true, requestType: .next)
    }

    func requestPrevData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        return doStateAction(forceRefresh: false, clearCacheBeforeFetching: false, clearCacheWhenFetchFails: false, continueWhenError: continueWhenError, awaitFetching: true, requestType: .prev)
    }

    private func doStateAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, continueWhenError: Bool, awaitFetching: Bool, requestType: RequestType) -> AnyPublisher<Void, Never> {
        async { _ in
            switch dataStateManager.load(key: key) {
            case .fixed(let nextDataState, let prevDataState):
                switch requestType {
                case .refresh:
                    if case .loading = nextDataState, case .loading = prevDataState {} else {
                        try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .refresh))
                    }
                case .next:
                    switch nextDataState {
                    case .fixed(let additionalRequestKey):
                        try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .next(requestKey: additionalRequestKey)))
                    case .fixedWithNoMoreAdditionalData:
                        break
                    case .loading(_):
                        break
                    case .error(let additionalRequestKey, _):
                        if continueWhenError { try `await`(doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .next(requestKey: additionalRequestKey))) }
                    }
                case .prev:
                    switch prevDataState {
                    case .fixed(let additionalRequestKey):
                        try `await`(doDataAction(forceRefresh: forceRefresh, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .prev(requestKey: additionalRequestKey)))
                    case .fixedWithNoMoreAdditionalData:
                        break
                    case .loading(_):
                        break
                    case .error(let additionalRequestKey, _):
                        if continueWhenError { try `await`(doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .prev(requestKey: additionalRequestKey))) }
                    }
                }
            case .loading:
                break
            case .error(_):
                switch requestType {
                case .refresh:
                    if continueWhenError { try `await`(doDataAction(forceRefresh: true, clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: .refresh)) }
                case .next, .prev:
                    dataStateManager.save(key: key, state: .error(rawError: AdditionalRequestOnErrorStateException()))
                }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func doDataAction(forceRefresh: Bool, clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, requestType: KeyedRequestType) -> AnyPublisher<Void, Never> {
        async { _ in
            let cachedData = try `await`(cacheDataManager.load())
            switch requestType {
            case .refresh:
                if cachedData == nil || forceRefresh || (try! `await`(needRefresh(cachedData!))) {
                    try `await`(prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: requestType))
                }
            case .next(_), .prev(_):
                if let _ = cachedData {
                    try `await`(prepareFetch(clearCacheBeforeFetching: clearCacheBeforeFetching, clearCacheWhenFetchFails: clearCacheWhenFetchFails, awaitFetching: awaitFetching, requestType: requestType))
                } else {
                    dataStateManager.save(key: key, state: .error(rawError: AdditionalRequestOnNilException()))
                }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func prepareFetch(clearCacheBeforeFetching: Bool, clearCacheWhenFetchFails: Bool, awaitFetching: Bool, requestType: KeyedRequestType) -> AnyPublisher<Void, Never> {
        async { _ in
            if clearCacheBeforeFetching { try `await`(cacheDataManager.save(newData: nil)) }
            let state = dataStateManager.load(key: key)
            switch requestType {
            case .refresh:
                dataStateManager.save(key: key, state: .loading)
            case .next(let requestKey):
                dataStateManager.save(key: key, state: .fixed(nextDataState: .loading(additionalRequestKey: requestKey), prevDataState: state.prevDataStateOrNil()))
            case .prev(let requestKey):
                dataStateManager.save(key: key, state: .fixed(nextDataState: state.nextDataStateOrNil(), prevDataState: .loading(additionalRequestKey: requestKey)))
            }
            if awaitFetching {
                try `await`(fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails, requestType: requestType))
            } else {
                _ = fetchNewData(clearCacheWhenFetchFails: clearCacheWhenFetchFails, requestType: requestType).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func fetchNewData(clearCacheWhenFetchFails: Bool, requestType: KeyedRequestType) -> AnyPublisher<Void, Never> {
        async { _ in
            do {
                let result: InternalFetched<DATA>
                switch requestType {
                case .refresh:
                    result = try `await`(originDataManager.fetch())
                case .next(let requestKey):
                    result = try `await`(originDataManager.fetchNext(nextKey: requestKey))
                case .prev(let requestKey):
                    result = try `await`(originDataManager.fetchPrev(prevKey: requestKey))
                }
                switch requestType {
                case .refresh:
                    try `await`(cacheDataManager.save(newData: result.data))
                case .next(_):
                    if let cachedData = try `await`(cacheDataManager.load()) {
                        try `await`(cacheDataManager.saveNext(cachedData: cachedData, newData: result.data))
                    } else {
                        throw AdditionalRequestOnNilException()
                    }
                case .prev(_):
                    if let cachedData = try `await`(cacheDataManager.load()) {
                        try `await`(cacheDataManager.savePrev(cachedData: cachedData, newData: result.data))
                    } else {
                        throw AdditionalRequestOnNilException()
                    }
                }
                let state = dataStateManager.load(key: key)
                switch (requestType) {
                case .refresh:
                    dataStateManager.save(key: key, state: .fixed(nextDataState: result.nextKey.isNilOrEmpty() ? .fixedWithNoMoreAdditionalData : .fixed(additionalRequestKey: result.nextKey!), prevDataState: result.prevKey.isNilOrEmpty() ? .fixedWithNoMoreAdditionalData : .fixed(additionalRequestKey: result.prevKey!)))
                case .next(_):
                    dataStateManager.save(key: key, state: .fixed(nextDataState: result.nextKey.isNilOrEmpty() ? .fixedWithNoMoreAdditionalData : .fixed(additionalRequestKey: result.nextKey!), prevDataState: state.prevDataStateOrNil()))
                case .prev(_):
                    dataStateManager.save(key: key, state: .fixed(nextDataState: state.nextDataStateOrNil(), prevDataState: result.prevKey.isNilOrEmpty() ? .fixedWithNoMoreAdditionalData : .fixed(additionalRequestKey: result.prevKey!)))
                }
            } catch {
                if clearCacheWhenFetchFails { try `await`(cacheDataManager.save(newData: nil)) }
                let state = dataStateManager.load(key: key)
                switch (requestType) {
                case .refresh:
                    dataStateManager.save(key: key, state: .error(rawError: error))
                case .next(let requestKey):
                    dataStateManager.save(key: key, state: .fixed(nextDataState: .error(additionalRequestKey: requestKey, rawError: error), prevDataState: state.prevDataStateOrNil()))
                case .prev(let requestKey):
                    dataStateManager.save(key: key, state: .fixed(nextDataState: state.nextDataStateOrNil(), prevDataState: .error(additionalRequestKey: requestKey, rawError: error)))
                }
            }
        }
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }
}
