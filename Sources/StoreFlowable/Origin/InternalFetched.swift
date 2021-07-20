//
//  InternalFetched.swift
//  
//
//  Created by tamura_k on 2021/07/19.
//

import Foundation

struct InternalFetched<DATA> {
    let data: DATA
    let nextKey: String?
    let prevKey: String?
}
