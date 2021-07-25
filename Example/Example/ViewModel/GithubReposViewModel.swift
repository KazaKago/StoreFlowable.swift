//
//  GithubReposViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import Combine

final class GithubReposViewModel : ObservableObject {

    @Published var githubRepos: [GithubRepo] = []
    @Published var isMainLoading: Bool = false
    @Published var isNextLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var mainError: Error?
    @Published var nextError: Error?
    private let userName: String
    private let githubReposRepository = GithubReposRepository()
    private var cancellableSet = Set<AnyCancellable>()

    init(userName: String) {
        self.userName = userName
    }

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func refresh() {
        githubReposRepository.refresh(userName: userName)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubReposRepository.refresh(userName: userName)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestNext() {
        githubReposRepository.requestNext(userName: userName, continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryNext() {
        githubReposRepository.requestNext(userName: userName, continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubReposRepository.follow(userName: userName)
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
            .store(in: &cancellableSet)
    }
}
