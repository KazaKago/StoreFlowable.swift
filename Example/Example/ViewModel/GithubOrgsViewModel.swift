//
//  GithubOrgsViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import Foundation

@MainActor
final class GithubOrgsViewModel : ObservableObject {

    @Published var githubOrgs: [GithubOrg] = []
    @Published var isMainLoading: Bool = false
    @Published var isNextLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var mainError: Error?
    @Published var nextError: Error?
    private let githubOrgsRepository = GithubOrgsRepository()

    func initialize() async {
        await subscribe()
    }

    func refresh() async {
        await githubOrgsRepository.refresh()
    }

    func retry() async {
        await githubOrgsRepository.refresh()
    }

    func requestNext() async {
        await githubOrgsRepository.requestNext(continueWhenError: false)
    }

    func retryNext() async {
        await githubOrgsRepository.requestNext(continueWhenError: true)
    }

    private func subscribe() async {
        for await state in githubOrgsRepository.follow() {
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
    }
}
