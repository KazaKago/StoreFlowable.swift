//
//  GithubUserViewModel.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

@MainActor
final class GithubUserViewModel : ObservableObject {

    @Published var githubUser: GithubUser?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let userName: String
    private let githubUserRepository = GithubUserRepository()

    init(userName: String) {
        self.userName = userName
    }

    func initialize() async {
        await subscribe()
    }

    func refresh() async {
        await githubUserRepository.refresh(userName: userName)
    }

    func retry() async {
        await githubUserRepository.refresh(userName: userName)
    }

    private func subscribe() async {
        for await state in githubUserRepository.follow(userName: userName) {
            state.doAction(
                onLoading: { _ in
                    self.githubUser = nil
                    self.isLoading = true
                    self.error = nil
                },
                onCompleted: { githubUser, _, _ in
                    self.githubUser = githubUser
                    self.isLoading = false
                    self.error = nil
                },
                onError: { error in
                    self.githubUser = nil
                    self.isLoading = false
                    self.error = error
                }
            )
        }
    }
}
