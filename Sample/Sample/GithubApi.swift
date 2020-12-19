//
//  GithubApi.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine

struct GithubApi {
    func getMeta() -> AnyPublisher<GithubMeta, Error> {
        Future { promise in
            let stub = GithubMeta(verifiablePasswordAuthentication: true, sshKeyFingerprints: SshKeyFingerprints(sha256Rsa: "sha256Rsa", sha256Dsa: "sha256Dsa"))
            promise(.success(stub))
        }
        .delay(for: .seconds(3), scheduler: RunLoop.main, options: .none)
        .eraseToAnyPublisher()
    }
}
