//
//  GithubTwoWayReposFlowableFactory.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine
import StoreFlowable

struct GithubTwoWayReposFlowableFactory: TwoWayPaginationStoreFlowableFactory {

    typealias PARAM = String
    typealias DATA = [GithubRepo]

    private static let EXPIRE_SECONDS = TimeInterval(60)
    private static let INITIAL_PAGE = 4
    private static let PER_PAGE = 20
    private let githubApi = GithubApi()

    let flowableDataStateManager: FlowableDataStateManager<String> = GithubTwoWayReposStateManager.shared

    func loadDataFromCache(param: String) -> AnyPublisher<[GithubRepo]?, Never> {
        Future { promise in
            promise(.success(GithubInMemoryCache.reposCache[param]))
        }.eraseToAnyPublisher()
    }

    func saveDataToCache(newData: [GithubRepo]?, param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[param] = newData
            GithubInMemoryCache.reposCacheCreatedAt[param] = Date()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func saveNextDataToCache(cachedData: [GithubRepo], newData: [GithubRepo], param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[param] = cachedData + newData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func savePrevDataToCache(cachedData: [GithubRepo], newData: [GithubRepo], param: String) -> AnyPublisher<Void, Never> {
        Future { promise in
            GithubInMemoryCache.reposCache[param] = newData + cachedData
            promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func fetchDataFromOrigin(param: String) -> AnyPublisher<FetchedInitial<[GithubRepo]>, Error> {
        githubApi.getRepos(userName: param, page: 4, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE).map { newData in
            FetchedInitial(
                data: newData,
                nextKey: newData.isEmpty ? nil : 5.description,
                prevKey: newData.isEmpty ? nil : 3.description
            )
        }.eraseToAnyPublisher()
    }

    func fetchNextDataFromOrigin(nextKey: String, param: String) -> AnyPublisher<FetchedNext<[GithubRepo]>, Error> {
        let nextPage = Int(nextKey)!
        return githubApi.getRepos(userName: param, page: nextPage, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE).map { newData in
            FetchedNext(
                data: newData,
                nextKey: newData.isEmpty ? nil : (nextPage + 1).description
            )
        }.eraseToAnyPublisher()
    }

    func fetchPrevDataFromOrigin(prevKey: String, param: String) -> AnyPublisher<FetchedPrev<[GithubRepo]>, Error> {
        let prevPage = Int(prevKey)!
        return githubApi.getRepos(userName: param, page: prevPage, perPage: GithubTwoWayReposFlowableFactory.PER_PAGE).map { newData in
            FetchedPrev(
                data: newData,
                prevKey: (prevPage > 1) ? (prevPage - 1).description : nil
            )
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [GithubRepo], param: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            if let createdAt = GithubInMemoryCache.reposCacheCreatedAt[param] {
                let expiredAt = createdAt + GithubTwoWayReposFlowableFactory.EXPIRE_SECONDS
                promise(.success(expiredAt < Date()))
            } else {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
}
