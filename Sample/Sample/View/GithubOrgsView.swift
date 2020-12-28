//
//  GithubOrgsView.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import SwiftUI

struct GithubOrgsView: View {

    @ObservedObject private var githubOrgsViewModel = GithubOrgsViewModel()

    var body: some View {
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
                Button("Refresh") {
                    githubOrgsViewModel.request()
                }
            }
        }
        .onAppear {
            githubOrgsViewModel.initialize()
        }
    }
}

struct GithubOrgsView_Previews: PreviewProvider {
    static var previews: some View {
        GithubOrgsView()
    }
}
