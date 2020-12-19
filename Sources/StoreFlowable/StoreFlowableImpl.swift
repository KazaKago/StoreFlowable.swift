//
//  StoreFlowableImpl.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/11.
//

import Foundation
import Combine
import CombineAsync

struct StoreFlowableImpl<KEY: Hashable, DATA>: StoreFlowable {

    typealias KEY = KEY
    typealias DATA = DATA

    private let storeFlowableResponder: AnyStoreFlowableResponder<KEY, DATA>
    private var dataSelector: DataSelector<KEY, DATA>

    init(storeFlowableResponder: AnyStoreFlowableResponder<KEY, DATA>) {
        self.storeFlowableResponder = storeFlowableResponder
        dataSelector = DataSelector(
            key: storeFlowableResponder.key,
            dataStateManager: AnyDataStateManager(storeFlowableResponder.flowableDataStateManager),
            cacheDataManager: AnyCacheDataManager(storeFlowableResponder),
            originDataManager: AnyOriginDataManager(storeFlowableResponder),
            needRefresh: { data in storeFlowableResponder.needRefresh(data: data) }
        )
    }

    func asFlow() -> AnyPublisher<State<DATA>, Error> {
        asFlow(forceRefresh: false)
    }

    func asFlow(forceRefresh: Bool) -> AnyPublisher<State<DATA>, Error> {
        dataSelector.doStateAction(forceRefresh: forceRefresh, clearCache: true, fetchAtError: false, fetchAsync: true)
            .flatMap { _ in
                storeFlowableResponder.flowableDataStateManager.getFlow(key: storeFlowableResponder.key)
            }
            .flatMap { dataState in
                dataSelector.load().map { data in
                    (dataState, data)
                }
            }
            .map { (dataState, data) in
                let stateContent = StateContent.wrap(rawContent: data)
                return dataState.mapState(stateContent: stateContent)
            }
            .eraseToAnyPublisher()
    }

    func get() -> AnyPublisher<DATA, Error> {
        get(type: .mix)
    }

    func get(type: AsDataType = .mix) -> AnyPublisher<DATA, Error> {
        async { yield in
            switch type {
            case .mix:
                try await(dataSelector.doStateAction(forceRefresh: false, clearCache: true, fetchAtError: false, fetchAsync: false))
            case .fromOrigin:
                try await(dataSelector.doStateAction(forceRefresh: true, clearCache: true, fetchAtError: false, fetchAsync: false))
            case .fromCache:
                //do nothing.
                break
            }
        }
        .flatMap {
            storeFlowableResponder.flowableDataStateManager.getFlow(key: storeFlowableResponder.key)
        }
        .flatMap { dataState in
            dataSelector.load().map { data in
                (dataState, data)
            }
        }
        .flatMap { (dataState, data) in
            async { yield in
                switch dataState {
                case .fixed:
                    if let data = data {
                        yield(data)
                    } else {
                        throw NoSuchElementError()
                    }
                case .loading:
                    // do nothing.
                    break
                case .error(let error):
                    if let data = data {
                        yield(data)
                    } else {
                        throw error
                    }
                }
            }
        }
        .first()
        .eraseToAnyPublisher()
    }

    func validate() -> AnyPublisher<Void, Error> {
        dataSelector.doStateAction(forceRefresh: false, clearCache: true, fetchAtError: false, fetchAsync: false)
    }

    func request() -> AnyPublisher<Void, Error> {
        dataSelector.doStateAction(forceRefresh: true, clearCache: false, fetchAtError: true, fetchAsync: false)
    }

    func update(newData: DATA?) -> AnyPublisher<Void, Error> {
        dataSelector.update(newData: newData)
    }
}
