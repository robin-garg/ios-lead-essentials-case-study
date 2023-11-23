//
//  LocalFeedImageDataLoader.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 23/11/23.
//

import XCTest

class LocalFeedImageDataLoader {
    init (store: Any) {
        
    }
}

final class LocalFeedImageDataLoaderTests : XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store:FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let messages = [Any]()
    }
}
