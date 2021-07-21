//
//  MainView.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import SwiftUI

struct MainView: View {

    @State private var nonPagenationGithubName = "github"
    @State private var oneWayPagenationGithubName = "github"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("This example accesses the Github API.\nThe valid time of these fetched data is 1 minute.")
                        .font(.caption)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                        .frame(height: 20)
                    Group {
                        Text("Non pagination example")
                            .font(.title2)
                            .bold()
                        Spacer()
                            .frame(height: 20)
                        NavigationLink(destination: GithubMetaView()) {
                            Text("Single cache")
                        }
                        Spacer()
                            .frame(height: 20)
                        NavigationLink(destination: GithubUserView(userName: nonPagenationGithubName)) {
                            Text("Per user cache")
                        }
                        Spacer()
                            .frame(height: 10)
                        TextField("Input any Github username", text: $nonPagenationGithubName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer()
                        .frame(height: 30)
                    Group {
                        Text("One-way pagination example")
                            .font(.title2)
                            .bold()
                        Spacer()
                            .frame(height: 20)
                        NavigationLink(destination: GithubOrgsView()) {
                            Text("Single one-way pagination")
                        }
                        Spacer()
                            .frame(height: 20)
                        NavigationLink(destination: GithubReposView(userName: oneWayPagenationGithubName)) {
                            Text("Per user one-way patination")
                        }
                        Spacer()
                            .frame(height: 10)
                        TextField("Input any Github username", text: $oneWayPagenationGithubName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Spacer()
                        .frame(height: 30)
                    Group {
                        Text("Two-way pagination example")
                            .font(.title2)
                            .bold()
                        Spacer()
                            .frame(height: 20)
                        NavigationLink(destination: GithubTwoWayReposView()) {
                            Text("Single two-way pagination")
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("StoreFlowable Example")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
