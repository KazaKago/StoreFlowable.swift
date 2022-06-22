//
//  GithubReposViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation

@MainActor
final class GithubReposViewModel : ObservableObject {

    @Published var githubRepos: [GithubRepo] = []
    @Published var isMainLoading: Bool = false
    @Published var isNextLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var mainError: Error?
    @Published var nextError: Error?
    private let userName: String
    private let githubReposRepository = GithubReposRepository()

    init(userName: String) {
        self.userName = userName
    }

    func initialize() async {
        await subscribe()
    }

    func refresh() async {
        await githubReposRepository.refresh(userName: userName)
    }

    func retry() async {
        await githubReposRepository.refresh(userName: userName)
    }

    func requestNext() async {
        await githubReposRepository.requestNext(userName: userName, continueWhenError: false)
    }

    func retryNext() async {
        await githubReposRepository.requestNext(userName: userName, continueWhenError: true)
    }

    private func subscribe() async {
        for await state in githubReposRepository.follow(userName: userName) {
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
                    self.mainError = nil
                    self.nextError = nil
                },
                onCompleted: { githubRepos, next, _ in
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
                    self.githubRepos = githubRepos
                    self.isMainLoading = false
                    self.isRefreshing = false
                    self.mainError = nil
                },
                onError: { error in
                    self.githubRepos = []
                    self.isMainLoading = false
                    self.isNextLoading = false
                    self.isRefreshing = false
                    self.mainError = error
                    self.nextError = nil
                }
            )
        }
    }
}
