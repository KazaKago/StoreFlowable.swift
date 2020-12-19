//
//  GithubMeta.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation

struct GithubMeta: Codable {
    let verifiablePasswordAuthentication: Bool
    let sshKeyFingerprints: SshKeyFingerprints

    enum CodingKeys: String, CodingKey {
        case verifiablePasswordAuthentication = "verifiable_password_authentication"
        case sshKeyFingerprints = "ssh_key_fingerprints"
   }
}

struct SshKeyFingerprints: Codable {
    let sha256Rsa: String
    let sha256Dsa: String

    enum CodingKeys: String, CodingKey {
        case sha256Rsa = "SHA256_RSA"
        case sha256Dsa = "SHA256_DSA"
   }
}
