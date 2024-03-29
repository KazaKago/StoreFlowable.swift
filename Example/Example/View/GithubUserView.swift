//
//  GithubUserView.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import SwiftUI
import KingfisherSwiftUI

struct GithubUserView: View {

    @ObservedObject private var githubUserViewModel: GithubUserViewModel

    init(userName: String) {
        githubUserViewModel = GithubUserViewModel(userName: userName)
    }

    var body: some View {
        ZStack {
            VStack {
                KFImage(URL(string: githubUserViewModel.githubUser?.avatarUrl ?? ""))
                    .resizable()
                    .frame(width: 128, height: 128)
                Spacer()
                    .frame(height: 20)
                if let id = githubUserViewModel.githubUser?.id {
                    Text("ID: \(id.description)")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
                if let name = githubUserViewModel.githubUser?.name {
                    Text(name)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                    .frame(height: 10)
                if let htmlUrl = githubUserViewModel.githubUser?.htmlUrl {
                    Link(htmlUrl, destination: URL(string: htmlUrl)!)
                        .foregroundColor(Color.blue)
                        .multilineTextAlignment(.center)
                }
            }
            if githubUserViewModel.isLoading {
                ProgressView()
            }
            if let error = githubUserViewModel.error {
                VStack {
                    Text(error.localizedDescription)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(height: 4)
                    Button("Retry") {
                        Task { await githubUserViewModel.retry() }
                    }
                }
                .padding()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    Task { await githubUserViewModel.refresh() }
                }
            }
        }
        .task {
            await githubUserViewModel.initialize()
        }
    }
}

struct GithubUserView_Previews: PreviewProvider {
    static var previews: some View {
        GithubUserView(userName: "Github")
    }
}
