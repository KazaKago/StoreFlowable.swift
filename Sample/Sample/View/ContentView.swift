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
var getOrNil: AnyCancellable?

struct ContentView: View {

    @ObservedObject private var mainViewModel = MainViewModel()

    var body: some View {
        VStack {
            Text(mainViewModel.text)
            Button("get") {
                let flowable = GithubMetaResponder().createStoreFlowable()
                get?.cancel()
                get = flowable.get()
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { error in
                        },
                        receiveValue: { value in
                            print(value)
                        }
                    )
            }
            Button("getOrNil") {
                let flowable = GithubMetaResponder().createStoreFlowable()
                getOrNil?.cancel()
                getOrNil = flowable.getOrNil()
                    .receive(on: DispatchQueue.main)
                    .sink { value in
                        if let value = value {
                            print(value)
                        } else {
                            print("nil")
                        }
                    }
            }
            Button("request") {
                mainViewModel.request()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
