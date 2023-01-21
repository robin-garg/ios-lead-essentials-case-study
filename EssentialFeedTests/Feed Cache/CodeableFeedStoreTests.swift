//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 14/01/23.
//

import XCTest
import EssentialFeed

final class CodeableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupStoreEmptyState()
    }
        
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toLoad: .empty)
    }
        
    func test_load_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toLoadTwice: .empty)
    }

    func test_load_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut: sut, toLoad: .found(feed: feed, timestamp: timestamp))
    }

    func test_load_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut: sut, toLoadTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_load_deliversFailureOnLoadError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toLoadTwice: .failure(anyNSError()))
    }

    func test_load_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut: sut, toLoad: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

        let latestFeed = uniqueImageFeed().local
        let latestDate = Date()
        let latestInsertionError = insert((latestFeed, latestDate), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        
        expect(sut: sut, toLoad: .found(feed: latestFeed, timestamp: latestDate))
    }
    
    func test_insert_deliversFailureOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut: sut, toLoad: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
        expect(sut: sut, toLoad: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut: sut, toLoad: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        var completedOperationsInOrder = [XCTestExpectation]()
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side effects to run serially but operations finished in the wrong order")
    }

    // MARK: - Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func deleteCache(sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        return deletionError
    }
        
    private func expect(sut: FeedStore, toLoadTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toLoad: expectedResult, file: file, line: line)
        expect(sut: sut, toLoad: expectedResult, file: file, line: line)
    }
    
    private func expect(sut: FeedStore, toLoad expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
    
    private func setupStoreEmptyState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
