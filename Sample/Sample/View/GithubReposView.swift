//
//  GithubReposView.swift
//  Sample
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
                                    githubReposViewModel.requestAdditional()
                                }
                            }
                    }
                    if githubReposViewModel.isAdditionalLoading {
                        LoadingItem()
                    }
                    if let error = githubReposViewModel.additionalError {
                        ErrorItem(error: error) {
                            githubReposViewModel.retryAdditional()
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
                            githubReposViewModel.retry()
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if githubReposViewModel.isMainLoading || githubReposViewModel.isAdditionalLoading {
                        ProgressView()
                    } else {
                        Button("Refresh") {
                            githubReposViewModel.refresh()
                            if let first = githubReposViewModel.githubRepos.first {
                                withAnimation { scrollProxy.scrollTo(first.id) }
                            }
                        }
                    }
                }
            }
            .onAppear {
                githubReposViewModel.initialize()
            }
        }
    }
}

struct GithubReposView_Previews: PreviewProvider {
    static var previews: some View {
        GithubReposView(userName: "github")
    }
}
