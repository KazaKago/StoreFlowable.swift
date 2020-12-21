//
//  ContentView.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import SwiftUI
import Combine
import StoreFlowable

var get: AnyCancellable?
var subscribe: AnyCancellable?
var request: AnyCancellable?

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Hello, world!")
            Button("get") {
                let flowable: AnyStoreFlowable<UnitHash, GithubMeta> = GithubMetaResponder().createStoreFlowable()
                get?.cancel()
                get = flowable.get().sink(
                    receiveCompletion: { error in
                        print(error)
                    },
                    receiveValue: { value in
                        print(value.sshKeyFingerprints)
                    }
                )
            }
            Button("subscribe") {
                let flowable: AnyStoreFlowable<UnitHash, GithubMeta> = GithubMetaResponder().createStoreFlowable()
                subscribe?.cancel()
                subscribe = flowable.asFlow().sink { state in
                    state.doAction(
                        onFixed: {
                            print("onFixed")
                        },
                        onLoading: {
                            print("onLoading")
                        },
                        onError: { error in
                            print("onError: \(error)")
                        }
                    )
                    state.stateContent.doAction(
                        onExist: { value in
                            print("onExist: \(value)")
                        },
                        onNotExist: {
                            print("onNotExist")
                        }
                    )
                }
            }
            Button("request") {
                let flowable: AnyStoreFlowable<UnitHash, GithubMeta> = GithubMetaResponder().createStoreFlowable()
                request?.cancel()
                request = flowable.request().sink {
                    print("request done!")
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
