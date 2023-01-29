//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Apple on 29/01/23.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupStoreEmptyState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().modals
        
        save(feed: feed, with: sutToPerformSave)
        
        expect(sut: sutToPerformLoad, toLoad: feed)
    }
    
    func test_load_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().modals
        let lastFeed = uniqueImageFeed().modals
        
        save(feed: firstFeed, with: sutToPerformFirstSave)
        save(feed: lastFeed, with: sutToPerformLastSave)
        
        expect(sut: sutToPerformLoad, toLoad: lastFeed)
    }
    
    // MARK:- Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func save(feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(feed) { result in
            if case let Result.failure(saveError) = result {
                XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(sut: LocalFeedLoader, toLoad expectedFeed:[FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead.", file: file, line: line)
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
