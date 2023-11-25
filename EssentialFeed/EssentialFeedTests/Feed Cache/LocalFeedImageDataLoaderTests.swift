//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 23/11/23.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrive(dataFromURL url: URL)
}

class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    private let store: FeedImageDataStore
    
    init (store: FeedImageDataStore) {
        self.store = store
    }
        
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrive(dataFromURL: url)
        return Task()
    }
}

final class LocalFeedImageDataLoaderTests : XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageData_requestsStoredDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrive(dataFrom: url)])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store:StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class StoreSpy: FeedImageDataStore {
        enum Messages: Equatable {
            case retrive(dataFrom: URL)
        }
        
        var receivedMessages = [Messages]()
        
        func retrive(dataFromURL url: URL) {
            receivedMessages.append(.retrive(dataFrom: url))
        }
    }
}
