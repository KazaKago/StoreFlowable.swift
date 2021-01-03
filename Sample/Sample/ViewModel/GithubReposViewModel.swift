//
//  GithubReposViewModel.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import Foundation
import Combine

final class GithubReposViewModel : ObservableObject {

    @Published var githubRepos: [GithubRepo] = []
    @Published var isMainLoading: Bool = false
    @Published var isAdditionalLoading: Bool = false
    @Published var mainError: Error?
    @Published var additionalError: Error?
    private let userName: String
    private let githubRepository = GithubRepository()
    private var cancellableSet = Set<AnyCancellable>()

    init(userName: String) {
        self.userName = userName
    }

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func request() {
        githubRepository.refreshRepos(userName: userName)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubRepository.refreshRepos(userName: userName)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestAdditional() {
        githubRepository.requestAdditionalRepos(userName: userName, continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryAdditional() {
        githubRepository.requestAdditionalRepos(userName: userName, continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubRepository.followRepos(userName: userName)
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onFixed: {
                        state.content.doAction(
                            onExist: { value in
                                self.githubRepos = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            },
                            onNotExist: {
                                self.githubRepos = []
                                self.isMainLoading = true
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            }
                        )
                    },
                    onLoading: {
                        state.content.doAction(
                            onExist: { value in
                                self.githubRepos = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = true
                                self.mainError = nil
                                self.additionalError = nil
                            },
                            onNotExist: {
                                self.githubRepos = []
                                self.isMainLoading = true
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            }
                        )
                    },
                    onError: { error in
                        state.content.doAction(
                            onExist: { value in
                                self.githubRepos = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = error
                            },
                            onNotExist: {
                                self.githubRepos = []
                                self.isMainLoading = false
                                self.isAdditionalLoading = false
                                self.mainError = error
                                self.additionalError = nil
                            }
                        )
                    }
                )
            }
            .store(in: &cancellableSet)
    }
}
