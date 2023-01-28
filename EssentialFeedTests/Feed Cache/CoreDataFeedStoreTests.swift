//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 22/01/23.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatLoadDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()

        assertThatLoadHasNoSideEffectOnEmptyCache(on: sut)
    }
    
    func test_load_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatLoadDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_load_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatLoadHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
    
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK:- Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}
