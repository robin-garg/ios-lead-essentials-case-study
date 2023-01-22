//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Apple on 22/01/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        return deletionError
    }
        
    func expect(sut: FeedStore, toLoadTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toLoad: expectedResult, file: file, line: line)
        expect(sut: sut, toLoad: expectedResult, file: file, line: line)
    }
    
    func expect(sut: FeedStore, toLoad expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrieval")
        sut.loadCachedFeed { loadedResult in
            switch (loadedResult, expectedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
            case let (.found(loaded), .found(expected)):
                XCTAssertEqual(loaded.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(loaded.timestamp, expected.timestamp, file: file, line: line)
                break
            default:
                XCTFail("Expected to load \(expectedResult), got \(loadedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
