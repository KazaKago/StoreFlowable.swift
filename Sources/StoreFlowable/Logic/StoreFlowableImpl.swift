//
//  StoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine
import CombineAsync

struct StoreFlowableImpl<PARAM: Hashable, DATA>: StoreFlowable, PaginationStoreFlowable, TwoWayPaginationStoreFlowable {

    typealias PARAM = PARAM
    typealias DATA = DATA

    private let param: PARAM
    private let flowableDataStateManager: FlowableDataStateManager<PARAM>
    private let cacheDataManager: AnyCacheDataManager<DATA>
    private let dataSelector: DataSelector<PARAM, DATA>

    init(param: PARAM, flowableDataStateManager: FlowableDataStateManager<PARAM>, cacheDataManager: AnyCacheDataManager<DATA>, originDataManager: AnyOriginDataManager<DATA>, needRefresh: @escaping (_ cachedData: DATA) -> AnyPublisher<Bool, Never>) {
        self.param = param
        self.flowableDataStateManager = flowableDataStateManager
        self.cacheDataManager = cacheDataManager
        self.dataSelector = DataSelector(
            param: param,
            dataStateManager: AnyDataStateManager(flowableDataStateManager),
            cacheDataManager: cacheDataManager,
            originDataManager: originDataManager,
            needRefresh: needRefresh
        )
    }

    func publish(forceRefresh: Bool) -> LoadingStatePublisher<DATA> {
        if forceRefresh {
            _ = dataSelector.refresh(clearCacheBeforeFetching: true).sink(receiveValue: {})
        } else {
            _ = dataSelector.validate().sink(receiveValue: {})
        }
        return flowableDataStateManager.getFlow(param: param)
            .flatMap { dataState in
                cacheDataManager.load().map { data in
                    (dataState, data)
                }
            }
            .compactMap { (dataState, data) in
                dataState.toLoadingState(content: data)
            }
            .eraseToAnyPublisher()
    }

    func getData(from: GettingFrom) -> AnyPublisher<DATA?, Never> {
        requireData(from: from)
            .map { data -> DATA? in
                data
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func requireData(from: GettingFrom) -> AnyPublisher<DATA, Error> {
        async { _ in
            switch from {
            case .both:
                try `await`(dataSelector.validate())
            case .origin:
                try `await`(dataSelector.refresh(clearCacheBeforeFetching: true))
            case .cache:
                break
            }
        }
        .flatMap {
            flowableDataStateManager.getFlow(param: param)
                .setFailureType(to: Error.self) // Workaround for macOS10.15/iOS13.0/tvOS13.0/watchOS6.0 https://www.donnywals.com/configuring-error-types-when-using-flatmap-in-combine/
        }
        .flatMap { dataState in
            dataSelector.loadValidCacheOrNil().map { data in
                (dataState, data)
            }
            .setFailureType(to: Error.self) // Workaround for macOS10.15/iOS13.0/tvOS13.0/watchOS6.0 https://www.donnywals.com/configuring-error-types-when-using-flatmap-in-combine/
        }
        .tryCompactMap { (dataState, data) in
            switch dataState {
            case .fixed:
                if let data = data { return data } else { throw NoSuchElementError() }
            case .loading:
                return nil
            case .error(let rawError):
                if let data = data { return data } else { throw rawError }
            }
        }
        .first()
        .eraseToAnyPublisher()
    }

    func validate() -> AnyPublisher<Void, Never> {
        dataSelector.validate()
    }

    func refresh() -> AnyPublisher<Void, Never> {
        dataSelector.refresh(clearCacheBeforeFetching: false)
    }

    func requestNextData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.requestNextData(continueWhenError: continueWhenError)
    }

    func requestPrevData(continueWhenError: Bool) -> AnyPublisher<Void, Never> {
        dataSelector.requestPrevData(continueWhenError: continueWhenError)
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData, nextKey: nil, prevKey: nil)
    }

    func update(newData: DATA?, nextKey: String?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData, nextKey: nextKey, prevKey: nil)
    }

    func update(newData: DATA?, nextKey: String?, prevKey: String?) -> AnyPublisher<Void, Never> {
        dataSelector.update(newData: newData, nextKey: nextKey, prevKey: prevKey)
    }
}
