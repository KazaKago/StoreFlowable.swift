//
//  MainView.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import SwiftUI

struct MainView: View {

    @State private var githubName = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Simple sample")
                Spacer()
                    .frame(height: 10)
                HStack {
                    NavigationLink(destination: GithubMetaView()) {
                        Text("Github Meta info\n(Single cache sample)")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                        .frame(width: 20)
                    NavigationLink(destination: GithubOrgsView()) {
                        Text("Github Organizations\n(Paging cache sample)")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
                    .frame(height: 30)
                Text("Per user sample")
                TextField("Input any Github username", text: $githubName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                Spacer()
                    .frame(height: 10)
                HStack {
                    NavigationLink(destination: GithubUserView(userName: githubName)) {
                        Text("Github User's info\n(Single cache sample)")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                        .frame(width: 20)
                    NavigationLink(destination: GithubReposView(userName: githubName)) {
                        Text("Github User's repos\n(Paging cache sample)")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
            .navigationBarTitle("StoreFlowable Sample")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
