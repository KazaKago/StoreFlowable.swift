//
//  GithubApi.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/16.
//

import Foundation
import Combine
import Alamofire

struct GithubApi {

    func getMeta() -> AnyPublisher<GithubMeta, Error> {
        return Future { promise in
            AF.request("https://api.github.com/meta")
                .response { response in
                    switch response.result {
                    case .success(let element): do {
                        let decodedResponse = try JSONDecoder().decode(GithubMeta.self, from: element!)
                        promise(.success(decodedResponse))
                    } catch {
                        promise(.failure(error))
                    }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
