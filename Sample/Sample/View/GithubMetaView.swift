//
//  GithubMetaView.swift
//  Sample
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
            if (githubMetaViewModel.isLoading) {
                ProgressView()
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    githubMetaViewModel.request()
                }
            }
        }
    }
}

struct GithubMetaView_Previews: PreviewProvider {
    static var previews: some View {
        GithubMetaView()
    }
}
