//
//  StateZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

public extension State {

    func zip<B, Z>(_ otherState: State<B>, _ transform: (_ content1: T, _ content2: B) -> Z) -> State<Z> {
        switch self {
        case .fixed(let content):
            switch otherState {
            case .fixed(let otherContent):
                return .fixed(content: content.zip(otherContent, transform))
            case .loading(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .error(let otherContent, let otherRawError):
                return .error(content: content.zip(otherContent, transform), rawError: otherRawError)
            }
        case .loading(let content):
            switch otherState {
            case .fixed(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .loading(let otherContent):
                return .loading(content: content.zip(otherContent, transform))
            case .error(let otherContent, let rawError):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            }
        case .error(let content, let rawError):
            switch otherState {
            case .fixed(let otherContent):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            case .loading(let otherContent):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            case .error(let otherContent, _):
                return .error(content: content.zip(otherContent, transform), rawError: rawError)
            }
        }
    }

    func zip<B, C, Z>(_ otherState1: State<B>, _ otherState2: State<C>, _ transform: (_ content1: T, _ content2: B, _ content3: C) -> Z) -> State<Z> {
        zip(otherState1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherState2) { (content1_2, content3) in
            transform(content1_2.0, content1_2.1, content3)
        }
    }

    func zip<B, C, D, Z>(_ otherState1: State<B>, _ otherState2: State<C>, _ otherState3: State<D>, _ transform: (_ content1: T, _ content2: B, _ content3: C, _ content4: D) -> Z) -> State<Z> {
        zip(otherState1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherState2) { (content1_2, content3) in
            (content1_2.0, content1_2.1, content3)
        }
        .zip(otherState3) { (content1_2_3, content4) in
            transform(content1_2_3.0, content1_2_3.1, content1_2_3.2, content4)
        }
    }

    func zip<B, C, D, E, Z>(_ otherState1: State<B>, _ otherState2: State<C>, _ otherState3: State<D>, _ otherState4: State<E>, _ transform: (_ content1: T, _ content2: B, _ content3: C, _ content4: D, _ content5: E) -> Z) -> State<Z> {
        zip(otherState1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherState2) { (content1_2, content3) in
            (content1_2.0, content1_2.1, content3)
        }
        .zip(otherState3) { (content1_2_3, content4) in
            (content1_2_3.0, content1_2_3.1, content1_2_3.2, content4)
        }
        .zip(otherState4) { (content1_2_3_4, content5) in
            transform(content1_2_3_4.0, content1_2_3_4.1, content1_2_3_4.2, content1_2_3_4.3, content5)
        }
    }
}
