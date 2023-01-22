//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 22/01/23.
//

import XCTest

private class CoreDataFeedStore {
    
}

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_load_deliversEmptyOnEmptyCache() {
        let sut = CoreDataFeedStore()
        
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_load_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_load_hasNoSideEffectsOnNonEmptyCache() {
        
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
}
