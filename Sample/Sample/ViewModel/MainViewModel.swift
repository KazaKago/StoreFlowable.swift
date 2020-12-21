//
//  MainViewModel.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/21.
//

import Foundation
import Combine

class MainViewModel : ObservableObject {

    @Published var text: String = ""
    private let githubRepository: GithubRepository = GithubRepository()
    private var cancellableSet = Set<AnyCancellable>()

    init() {
        subscribe()
    }

    private func subscribe() {
        githubRepository.followMeta()
            .receive(on: DispatchQueue.main)
            .sink { state in
                state.doAction(
                    onFixed: {
                        state.stateContent.doAction(
                            onExist: { value in
                                self.text = "onFixed: onExist: \(value)"
                            },
                            onNotExist: {
                                self.text = "onFixed: onNotExist"
                            }
                        )
                    },
                    onLoading: {
                        state.stateContent.doAction(
                            onExist: { value in
                                self.text = "onLoading: onExist: \(value)"
                            },
                            onNotExist: {
                                self.text = "onLoading: onNotExist"
                            }
                        )
                    },
                    onError: { error in
                        state.stateContent.doAction(
                            onExist: { value in
                                self.text = "onError: \(error) onExist: \(value)"
                            },
                            onNotExist: {
                                self.text = "onError: \(error) onNotExist"
                            }
                        )
                    }
                )
            }
            .store(in: &cancellableSet)
    }

    func request() {
        githubRepository.requestMeta()
            .receive(on: DispatchQueue.main)
            .sink {}
            .store(in: &cancellableSet)
    }
}
