//
//  GithubRepoItem.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/29.
//

import SwiftUI

struct GithubRepoItem: View {

    let githubRepo: GithubRepo

    var body: some View {
        VStack(alignment: .leading) {
            Text("ID: \(githubRepo.id.description)")
                .font(.caption)
            Spacer()
                .frame(height: 4)
            Text(githubRepo.fullName)
                .font(.body)
            Spacer()
                .frame(height: 4)
            Link(githubRepo.htmlUrl, destination: URL(string: githubRepo.htmlUrl)!)
                .foregroundColor(Color.blue)
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

struct GithubRepoItem_Previews: PreviewProvider {
    static var previews: some View {
        GithubRepoItem(githubRepo: GithubRepo(id: 1223, fullName: "User Name", htmlUrl: "http://example.com"))
    }
}
