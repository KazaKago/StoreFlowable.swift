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
    private let githubRepository = GithubRepository()
    private var cancellableSet = Set<AnyCancellable>()

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func refresh() {
        githubRepository.refreshMeta()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubRepository.refreshMeta()
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
