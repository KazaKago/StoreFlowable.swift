//
//  GithubMetaViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import Foundation

@MainActor
final class GithubMetaViewModel : ObservableObject {

    @Published var githubMeta: GithubMeta?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let githubMetaRepository = GithubMetaRepository()

    func initialize() async {
        await subscribe()
    }

    func refresh() async {
        await githubMetaRepository.refresh()
    }

    func retry() async {
        await githubMetaRepository.refresh()
    }

    private func subscribe() async {
        for await state in githubMetaRepository.follow() {
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
    }
}
