//
//  XCTestCase+FailableLoadFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Apple on 22/01/23.
//

import XCTest
import EssentialFeed

extension FailableLoadFeedStoreSpecs where Self: XCTestCase {
    func assertLoadDeliversFailureOnLoadError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toLoadTwice: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatLoadHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toLoad: .failure(anyNSError()), file: file, line: line)
    }
}
