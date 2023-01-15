//
//  CodeableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 14/01/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
        
    private var storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        public init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
    }
    
    func loadCachedFeed(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodeableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
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

    func test_loadAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableFeedStore()
        
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(feed.local, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.loadCachedFeed { loadedResult in
                switch loadedResult {
                case let .found(feed: loadedFeed, timestamp: loadedTimestamp):
                    XCTAssertEqual(feed.local, loadedFeed)
                    XCTAssertEqual(timestamp, loadedTimestamp)
                    break
                default:
                    XCTFail("Expected load result with \(feed) and \(timestamp), got \(loadedResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

}
