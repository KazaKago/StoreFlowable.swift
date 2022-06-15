//
//  GithubTwoWayReposViewModel.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import Foundation

@MainActor
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
    var firstLoad = true

    func initialize() async {
        await subscribe()
    }

    func refresh() async {
        await githubTwoWayReposRepository.refresh()
    }

    func retry() async {
        await githubTwoWayReposRepository.refresh()
    }

    func requestNext() async {
        await githubTwoWayReposRepository.requestNext(continueWhenError: false)
    }

    func requestPrev() async {
        await githubTwoWayReposRepository.requestPrev(continueWhenError: false)
    }

    func retryNext() async {
        await githubTwoWayReposRepository.requestNext(continueWhenError: true)
    }

    func retryPrev() async {
        await githubTwoWayReposRepository.requestPrev(continueWhenError: true)
    }

    private func subscribe() async {
        do {
            for try await state in githubTwoWayReposRepository.follow() {
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
        } catch { /* do nothing. */ }
    }
}
