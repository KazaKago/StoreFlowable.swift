//
//  GithubMetaViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation
import Combine

final class GithubMetaViewModel : ObservableObject {

    @Published var githubMeta: GithubMeta?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let githubMetaRepository = GithubMetaRepository()
    private var cancellableSet = Set<AnyCancellable>()

    func initialize() {
        cancellableSet.removeAll()
        subscribe()
    }

    func refresh() {
        githubMetaRepository.refresh()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    func retry() {
        githubMetaRepository.refresh()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }

    private func subscribe() {
        githubMetaRepository.follow()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onLoading: { _ in
                        self.githubMeta = nil
                        self.isLoading = true
                        self.error = nil
                    },
                    onCompleted: { githubMeta, _, _ in
                        self.githubMeta = githubMeta
                        self.isLoading = false
                        self.error = nil
                    },
                    onError: { error in
                        self.githubMeta = nil
                        self.isLoading = false
                        self.error = error
                    }
                )
            }
            .store(in: &cancellableSet)
    }
}
