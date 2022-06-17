//
//  GithubReposView.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import SwiftUI

struct GithubReposView: View {

    @ObservedObject private var githubReposViewModel: GithubReposViewModel

    init(userName: String) {
        githubReposViewModel = GithubReposViewModel(userName: userName)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                List {
                    ForEach(githubReposViewModel.githubRepos) { githubRepo in
                        GithubRepoItem(githubRepo: githubRepo)
                            .onAppear {
                                if githubRepo == githubReposViewModel.githubRepos.last {
                                    Task { await githubReposViewModel.requestNext() }
                                }
                            }
                    }
                    if githubReposViewModel.isNextLoading {
                        LoadingItem()
                    }
                    if let error = githubReposViewModel.nextError {
                        ErrorItem(error: error) {
                            Task { await githubReposViewModel.retryNext() }
                        }
                    }
                }
                if githubReposViewModel.isMainLoading {
                    ProgressView()
                }
                if let error = githubReposViewModel.mainError {
                    VStack {
                        Text(error.localizedDescription)
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                        Spacer()
                            .frame(height: 4)
                        Button("Retry") {
                            Task { await githubReposViewModel.retry() }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if githubReposViewModel.isMainLoading || githubReposViewModel.isNextLoading || githubReposViewModel.isRefreshing {
                        ProgressView()
                    } else {
                        Button("Refresh") {
                            Task { await githubReposViewModel.refresh() }
                            if let first = githubReposViewModel.githubRepos.first {
                                withAnimation { scrollProxy.scrollTo(first.id) }
                            }
                        }
                    }
                }
            }
            .task {
                await githubReposViewModel.initialize()
            }
        }
    }
}

struct GithubReposView_Previews: PreviewProvider {
    static var previews: some View {
        GithubReposView(userName: "github")
    }
}
