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
    @Published var refreshingError: Error?
    @Published var isShowRefreshingError: Bool = false
    private let githubRepository = GithubRepository()
    private var shouldNoticeErrorOnNextState: Bool = false
    private var cancellableSet = Set<AnyCancellable>()

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func request() {
        shouldNoticeErrorOnNextState = true
        githubRepository.requestOrgs()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubRepository.requestOrgs()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func requestAdditional() {
        githubRepository.requestAdditionalOrgs(fetchAtError: false)
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retryAdditional() {
        githubRepository.requestAdditionalOrgs(fetchAtError: true)
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
                        self.shouldNoticeErrorOnNextState = false
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
                        if self.shouldNoticeErrorOnNextState {
                            self.refreshingError = error
                            self.isShowRefreshingError = true
                        }
                        self.shouldNoticeErrorOnNextState = false
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
