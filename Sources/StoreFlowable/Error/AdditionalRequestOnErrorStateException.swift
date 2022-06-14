//
//  AdditionalRequestOnErrorStateException.swift
//  StoreFlowable
//
//  Created by tamura_k on 2021/07/19.
//

/**
 * This Exception occurs when `requestNextData()` or `requestPrevData()` is called on `DataState.Error`.
 */
public class AdditionalRequestOnErrorStateException: Error {
}
