//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 30/11/23.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Messages: Equatable {
        case insert(data: Data, for: URL)
        case retrive(dataFrom: URL)
    }
    
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    private(set) var receivedMessages = [Messages]()
    
    func retrive(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrive(dataFrom: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertion(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
