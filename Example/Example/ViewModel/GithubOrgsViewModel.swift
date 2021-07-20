//
//  GithubOrgsViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import Foundation
import Combine

final class GithubOrgsViewModel : ObservableObject {

    @Published var githubOrgs: [GithubOrg] = []
    @Published var isMainLoading: Bool = false
    @Published var isNextLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var mainError: Error?
    @Published var nextError: Error?
    private let githubRepository = GithubRepository()
    private var cancellableSet = Set<AnyCancellable>()

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func refresh() {
        githubRepository.refreshOrgs()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubRepository.refreshOrgs()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestNext() {
        githubRepository.requestNextOrgs(continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryNext() {
        githubRepository.requestNextOrgs(continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubRepository.followOrgs()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onLoading: { githubOrgs in
                        if let githubOrgs = githubOrgs {
                            self.githubOrgs = githubOrgs
                            self.isMainLoading = false
                            self.isRefreshing = true
                        } else {
                            self.githubOrgs = []
                            self.isMainLoading = true
                            self.isRefreshing = true
                        }
                        self.isNextLoading = false
                        self.mainError = nil
                        self.nextError = nil
                    },
                    onCompleted: { githubOrgs, next, _ in
                        next.doAction(
                            onFixed: {_ in
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
                        self.githubOrgs = githubOrgs
                        self.isMainLoading = false
                        self.isRefreshing = false
                        self.mainError = nil
                    },
                    onError: { error in
                        self.githubOrgs = []
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
