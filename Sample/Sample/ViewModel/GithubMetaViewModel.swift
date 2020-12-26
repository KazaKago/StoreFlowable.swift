//
//  GithubMetaViewModel.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

final class GithubMetaViewModel : ObservableObject {

    @Published var githubMeta: GithubMeta?
    @Published var isLoading: Bool = false
    @Published var error: Error?
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
        githubRepository.requestMeta()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubRepository.requestMeta()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubRepository.followMeta()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onFixed: {
                        self.shouldNoticeErrorOnNextState = false
                        state.stateContent.doAction(
                            onExist: { value in
                                self.githubMeta = value
                                self.isLoading = false
                                self.error = nil
                            },
                            onNotExist: {
                                self.githubMeta = nil
                                self.isLoading = false
                                self.error = nil
                            }
                        )
                    },
                    onLoading: {
                        state.stateContent.doAction(
                            onExist: { value in
                                self.githubMeta = value
                                self.isLoading = true
                                self.error = nil
                            },
                            onNotExist: {
                                self.githubMeta = nil
                                self.isLoading = true
                                self.error = nil
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
                                self.githubMeta = value
                                self.isLoading = false
                                self.error = nil
                            },
                            onNotExist: {
                                self.githubMeta = nil
                                self.isLoading = false
                                self.error = error
                            }
                        )
                    }
                )
            }
            .store(in: &cancellableSet)
    }
}
