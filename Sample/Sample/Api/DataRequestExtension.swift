//
//  DataRequestExtension.swift
//  Sample
//
//  Created by Kensuke Tamura on 2020/12/24.
//

import Foundation
import Combine
import Alamofire

extension DataRequest {

    func publishResponse<T>(_ type: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        Future { promise in
            self.response { response in
                switch response.result {
                case .success(let element): do {
                    let decodedResponse = try JSONDecoder().decode(type, from: element!)
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
