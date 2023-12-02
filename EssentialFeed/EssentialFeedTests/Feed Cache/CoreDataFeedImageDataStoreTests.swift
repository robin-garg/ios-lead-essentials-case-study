//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 02/12/23.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrive(dataFromURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedImageDataStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func expect(_ sut: FeedImageDataStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrive(dataFromURL: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
