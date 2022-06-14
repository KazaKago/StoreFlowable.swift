//
//  RequestKeyManager.swift
//  
//
//  Created by Kensuke Tamura on 2022/06/07.
//

protocol RequestKeyManager {

    func loadNext() async -> String?

    func saveNext(requestKey: String?) async

    func loadPrev() async -> String?

    func savePrev(requestKey: String?) async
}
