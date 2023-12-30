//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 01/01/23.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrievalWithNoCachedImages()
        
        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed])
    }
    
    func test_validateCache_doesNotDeletesCacheOnNonExpiredCache() {
        let feed = uniqueImageFeed() 
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed])
    }
    
    func test_validateCache_deletesCacheOnExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed, .deleteCachedFeed])
    }

    func test_validateCache_deletesCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache { _ in }
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.loadCachedFeed])
    }


    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
}
