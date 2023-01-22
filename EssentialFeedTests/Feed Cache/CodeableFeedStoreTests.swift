//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 14/01/23.
//

import XCTest
import EssentialFeed

final class CodeableFeedStoreTests: XCTestCase, FailableFeedStore {
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)

        let latestFeed = uniqueImageFeed().local
        let latestDate = Date()
        insert((latestFeed, latestDate), to: sut)
        
        expect(sut: sut, toLoad: .found(feed: latestFeed, timestamp: latestDate))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_insert_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toLoad: .empty)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(sut: sut)
        
        expect(sut: sut, toLoad: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(sut: sut)
        
        expect(sut: sut, toLoad: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(sut: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(sut: sut)
        
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
