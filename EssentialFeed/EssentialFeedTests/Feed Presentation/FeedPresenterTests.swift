//
//  FeedPresentatoinTests.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 09/11/23.
//

import XCTest


final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresentationTests: XCTestCase {
    
    func test_init_doesNotSendAnyMessageOnInit() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertEqual(view.messages.count, 0)
    }
 
    // MARK: - Helpers
    private class ViewSpy {
        let messages = [Any]()
    }
}
