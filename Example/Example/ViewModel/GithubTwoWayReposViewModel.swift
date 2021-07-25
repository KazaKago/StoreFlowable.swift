//
//  GithubTwoWayReposViewModel.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation
import Combine

final class GithubTwoWayReposViewModel : ObservableObject {

    @Published var githubRepos: [GithubRepo] = []
    @Published var isMainLoading: Bool = false
    @Published var isNextLoading: Bool = false
    @Published var isPrevLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var mainError: Error?
    @Published var nextError: Error?
    @Published var prevError: Error?
    private let githubTwoWayReposRepository = GithubTwoWayReposRepository()
    private var cancellableSet = Set<AnyCancellable>()
    var firstLoad = true

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func refresh() {
        githubTwoWayReposRepository.refresh()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubTwoWayReposRepository.refresh()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestNext() {
        githubTwoWayReposRepository.requestNext(continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestPrev() {
        githubTwoWayReposRepository.requestPrev(continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryNext() {
        githubTwoWayReposRepository.requestNext(continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryPrev() {
        githubTwoWayReposRepository.requestPrev(continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubTwoWayReposRepository.follow()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onLoading: { githubRepos in
                        if let githubRepos = githubRepos {
                            self.githubRepos = githubRepos
                            self.isMainLoading = false
                            self.isRefreshing = true
                        } else {
                            self.githubRepos = []
                            self.isMainLoading = true
                            self.isRefreshing = false
                        }
                        self.isNextLoading = false
                        self.isPrevLoading = false
                        self.mainError = nil
                        self.nextError = nil
                        self.prevError = nil
                    },
                    onCompleted: { githubRepos, next, prev in
                        self.githubRepos = githubRepos
                        next.doAction(
                            onFixed: { _ in
                                self.isNextLoading = false
                                self.nextError = nil
                            },
                            onLoading: {
                                self.isNextLoading = true
                                self.nextError = nil
                            },
                            onError: { error in
                                self.isNextLoading = false
                                self.nextError = error
                            }
                        )
                        prev.doAction(
                            onFixed: { _ in
                                self.isPrevLoading = false
                                self.prevError = nil
                            },
                            onLoading: {
                                self.isPrevLoading = true
                                self.prevError = nil
                            },
                            onError: { error in
                                self.isPrevLoading = false
                                self.prevError = error
                            }
                        )
                        self.isMainLoading = false
                        self.isRefreshing = false
                        self.mainError = nil
                    },
                    onError: { error in
                        self.githubRepos = []
                        self.isMainLoading = false
                        self.isNextLoading = false
                        self.isPrevLoading = false
                        self.isRefreshing = false
                        self.mainError = error
                        self.nextError = nil
                        self.prevError = nil
                    }
                )
            }
            .store(in: &cancellableSet)
    }
}
