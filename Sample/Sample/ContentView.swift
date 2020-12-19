//
//  ContentView.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import SwiftUI
import Combine
import StoreFlowable

var subscribe: AnyCancellable?
var request: AnyCancellable?

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Hello, world!")
            Button("subscribe") {
                let flowable: AnyStoreFlowable<String, GithubMeta> = GithubMetaResponder(key: "").createStoreFlowable()
                subscribe?.cancel()
                subscribe = flowable.asFlow().sink { error in
                    print(error)
                } receiveValue: { value in
                    print(value)
                }
            }
            Button("request") {
                let flowable: AnyStoreFlowable<String, GithubMeta> = GithubMetaResponder(key: "").createStoreFlowable()
                request?.cancel()
                request = flowable.request().sink { _ in
                } receiveValue: { _ in
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
