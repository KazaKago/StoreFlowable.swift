//
//  StateContentZipper.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/12/28.
//

import Foundation

public extension StateContent {

    func zip<B, Z>(_ otherStateContent: StateContent<B>, _ transform: (_ content1: T, _ content2: B) -> Z) -> StateContent<Z> {
        switch self {
        case .exist(let rawContent):
            switch otherStateContent {
            case .exist(let otherRawContent):
                return .exist(rawContent: transform(rawContent, otherRawContent))
            case .notExist:
                return .notExist
            }
        case .notExist:
            switch otherStateContent {
            case .exist(_):
                return .notExist
            case .notExist:
                return .notExist
            }
        }
    }

    func zip<B, C, Z>(_ otherStateContent1: StateContent<B>, _ otherStateContent2: StateContent<C>, _ transform: (_ content1: T, _ content2: B, _ content3: C) -> Z) -> StateContent<Z> {
        zip(otherStateContent1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherStateContent2) { (content1_2, content3) in
            transform(content1_2.0, content1_2.1, content3)
        }
    }

    func zip<B, C, D, Z>(_ otherStateContent1: StateContent<B>, _ otherStateContent2: StateContent<C>, _ otherStateContent3: StateContent<D>, _ transform: (_ content1: T, _ content2: B, _ content3: C, _ content4: D) -> Z) -> StateContent<Z> {
        zip(otherStateContent1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherStateContent2) { (content1_2, content3) in
            (content1_2.0, content1_2.1, content3)
        }
        .zip(otherStateContent3) { (content1_2_3, content4) in
            transform(content1_2_3.0, content1_2_3.1, content1_2_3.2, content4)
        }
    }

    func zip<B, C, D, E, Z>(_ otherStateContent1: StateContent<B>, _ otherStateContent2: StateContent<C>, _ otherStateContent3: StateContent<D>, _ otherStateContent4: StateContent<E>, _ transform: (_ content1: T, _ content2: B, _ content3: C, _ content4: D, _ content5: E) -> Z) -> StateContent<Z> {
        zip(otherStateContent1) { (content1, content2) in
            (content1, content2)
        }
        .zip(otherStateContent2) { (content1_2, content3) in
            (content1_2.0, content1_2.1, content3)
        }
        .zip(otherStateContent3) { (content1_2_3, content4) in
            (content1_2_3.0, content1_2_3.1, content1_2_3.2, content4)
        }
        .zip(otherStateContent4) { (content1_2_3_4, content5) in
            transform(content1_2_3_4.0, content1_2_3_4.1, content1_2_3_4.2, content1_2_3_4.3, content5)
        }
    }
}
