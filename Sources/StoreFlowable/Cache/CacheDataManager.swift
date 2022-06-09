//
//  CacheDataManager.swift
//  StoreFlowable
//
//  Created by Kensuke Tamura on 2020/11/29.
//

import Foundation

protocol CacheDataManager {

    associatedtype DATA

    func load() async -> DATA?

    func save(newData: DATA?) async
    
    func saveNext(cachedData: DATA, newData: DATA) async

    func savePrev(cachedData: DATA, newData: DATA) async
}
