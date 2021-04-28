//
//  GithubOrgsView.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import SwiftUI

struct GithubOrgsView: View {

    @ObservedObject private var githubOrgsViewModel = GithubOrgsViewModel()

    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                List {
                    ForEach(githubOrgsViewModel.githubOrgs) { githubOrg in
                        GithubOrgItem(githubOrg: githubOrg)
                            .onAppear {
                                if githubOrg == githubOrgsViewModel.githubOrgs.last {
                                    githubOrgsViewModel.requestAdditional()
                                }
                            }
                    }
                    if githubOrgsViewModel.isAdditionalLoading {
                        LoadingItem()
                    }
                    if let error = githubOrgsViewModel.additionalError {
                        ErrorItem(error: error) {
                            githubOrgsViewModel.retryAdditional()
                        }
                    }
                }
                if githubOrgsViewModel.isMainLoading {
                    ProgressView()
                }
                if let error = githubOrgsViewModel.mainError {
                    VStack {
                        Text(error.localizedDescription)
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                        Spacer()
                            .frame(height: 4)
                        Button("Retry") {
                            githubOrgsViewModel.retry()
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if githubOrgsViewModel.isMainLoading || githubOrgsViewModel.isAdditionalLoading {
                        ProgressView()
                    } else {
                        Button("Refresh") {
                            githubOrgsViewModel.refresh()
                            if let first = githubOrgsViewModel.githubOrgs.first {
                                withAnimation { scrollProxy.scrollTo(first.id) }
                            }
                        }
                    }
                }
            }
            .onAppear {
                githubOrgsViewModel.initialize()
            }
        }
    }
}

struct GithubOrgsView_Previews: PreviewProvider {
    static var previews: some View {
        GithubOrgsView()
    }
}
