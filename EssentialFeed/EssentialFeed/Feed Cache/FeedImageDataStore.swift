//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Netsmartz on 29/11/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrive(dataFromURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
