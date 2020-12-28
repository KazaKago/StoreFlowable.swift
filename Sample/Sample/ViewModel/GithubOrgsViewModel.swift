//
//  GithubOrgsViewModel.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import Foundation
import Combine

final class GithubOrgsViewModel : ObservableObject {

    @Published var githubOrgs: [GithubOrg] = []
    @Published var isMainLoading: Bool = false
    @Published var isAdditionalLoading: Bool = false
    @Published var mainError: Error?
    @Published var additionalError: Error?
    private let githubRepository = GithubRepository()
    private var cancellableSet = Set<AnyCancellable>()

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func request() {
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

    func requestAdditional() {
        githubRepository.requestAdditionalOrgs(continueWhenError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryAdditional() {
        githubRepository.requestAdditionalOrgs(continueWhenError: true)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubRepository.followOrgs()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onFixed: {
                        state.stateContent.doAction(
                            onExist: { value in
                                self.githubOrgs = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            },
                            onNotExist: {
                                self.githubOrgs = []
                                self.isMainLoading = true
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            }
                        )
                    },
                    onLoading: {
                        state.stateContent.doAction(
                            onExist: { value in
                                self.githubOrgs = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = true
                                self.mainError = nil
                                self.additionalError = nil
                            },
                            onNotExist: {
                                self.githubOrgs = []
                                self.isMainLoading = true
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = nil
                            }
                        )
                    },
                    onError: { error in
                        state.stateContent.doAction(
                            onExist: { value in
                                self.githubOrgs = value
                                self.isMainLoading = false
                                self.isAdditionalLoading = false
                                self.mainError = nil
                                self.additionalError = error
                            },
                            onNotExist: {
                                self.githubOrgs = []
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
