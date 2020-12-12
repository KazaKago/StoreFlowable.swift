//
//  SampleApp.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/11/28.
//

import SwiftUI
import StoreFlowable

@main
struct SampleApp: App {
    var body: some Scene {
        let state = State.fixed(stateContent: StateContent.exist(rawContent: 1))
        let _ = state.doAction(
            onFixed: {
            },
            onLoading: {
            },
            onError: { error in
            }
        )
        let _ = state.stateContent.doAction(
            onExist: { rawContent in
            },
            onNotExist: {
            }
        )
        WindowGroup {
            ContentView()
        }
    }
}
