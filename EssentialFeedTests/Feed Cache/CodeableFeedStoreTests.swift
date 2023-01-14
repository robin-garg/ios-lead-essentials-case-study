//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 14/01/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func loadCachedFeed(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodeableFeedStoreTests: XCTestCase {
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for cache retrieval")
        sut.loadCachedFeed { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for cache retrieval")
        sut.loadCachedFeed { firstResult in
            sut.loadCachedFeed { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected load twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }

                exp.fulfill()
            }
            
        }
        wait(for: [exp], timeout: 1.0)
    }

}
