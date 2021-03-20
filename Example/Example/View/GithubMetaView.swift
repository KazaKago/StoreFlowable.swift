//
//  GithubMetaView.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/23.
//

import SwiftUI

struct GithubMetaView: View {

    @ObservedObject private var githubMetaViewModel = GithubMetaViewModel()

    var body: some View {
        ZStack {
            VStack {
                if let sha256Rsa = githubMetaViewModel.githubMeta?.sshKeyFingerprints.sha256Rsa {
                    Text("SHA256_RSA\n\(sha256Rsa)")
                        .multilineTextAlignment(.center)
                }
                Spacer()
                    .frame(height: 20)
                if let sha256Dsa = githubMetaViewModel.githubMeta?.sshKeyFingerprints.sha256Dsa {
                    Text("SHA256_DSA\n\(sha256Dsa)")
                        .multilineTextAlignment(.center)
                }
            }
            if githubMetaViewModel.isLoading {
                ProgressView()
            }
            if let error = githubMetaViewModel.error {
                VStack {
                    Text(error.localizedDescription)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                    Spacer()
                        .frame(height: 4)
                    Button("Retry") {
                        githubMetaViewModel.retry()
                    }
                }
                .padding()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    githubMetaViewModel.refresh()
                }
            }
        }
        .onAppear {
            githubMetaViewModel.initialize()
        }
    }
}

struct GithubMetaView_Previews: PreviewProvider {
    static var previews: some View {
        GithubMetaView()
    }
}
