//
//  GithubTwoWayReposView.swift
//  Example
//
//  Created by tamura_k on 2021/07/21.
//

import SwiftUI

struct GithubTwoWayReposView: View {

    @ObservedObject private var githubTwoWayReposViewModel: GithubTwoWayReposViewModel

    init() {
        githubTwoWayReposViewModel = GithubTwoWayReposViewModel()
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                List {
                    if githubTwoWayReposViewModel.isPrevLoading {
                        LoadingItem()
                    }
                    if let error = githubTwoWayReposViewModel.prevError {
                        ErrorItem(error: error) {
                            githubTwoWayReposViewModel.retryPrev()
                        }
                    }
                    ForEach(githubTwoWayReposViewModel.githubRepos) { githubRepo in
                        GithubRepoItem(githubRepo: githubRepo)
                            .onAppear {
                                if !githubTwoWayReposViewModel.githubRepos.isEmpty && githubTwoWayReposViewModel.firstLoad {
                                    githubTwoWayReposViewModel.firstLoad = false
                                    scrollProxy.scrollTo(githubTwoWayReposViewModel.githubRepos[8].id)
                                }
                                if githubRepo == githubTwoWayReposViewModel.githubRepos.first {
                                    githubTwoWayReposViewModel.requestPrev()
                                }
                                if githubRepo == githubTwoWayReposViewModel.githubRepos.last {
                                    githubTwoWayReposViewModel.requestNext()
                                }
                            }
                    }
                    if githubTwoWayReposViewModel.isNextLoading {
                        LoadingItem()
                    }
                    if let error = githubTwoWayReposViewModel.nextError {
                        ErrorItem(error: error) {
                            githubTwoWayReposViewModel.retryNext()
                        }
                    }
                }
                if githubTwoWayReposViewModel.isMainLoading {
                    ProgressView()
                }
                if let error = githubTwoWayReposViewModel.mainError {
                    VStack {
                        Text(error.localizedDescription)
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                        Spacer()
                            .frame(height: 4)
                        Button("Retry") {
                            githubTwoWayReposViewModel.retry()
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                githubTwoWayReposViewModel.initialize()
            }
        }
    }
}

struct GithubTwoWayReposView_Previews: PreviewProvider {
    static var previews: some View {
        GithubTwoWayReposView()
    }
}
