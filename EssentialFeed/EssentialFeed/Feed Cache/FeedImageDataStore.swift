//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Netsmartz on 29/11/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrive(dataFromURL url: URL, completion: @escaping (Result) -> Void)
}
