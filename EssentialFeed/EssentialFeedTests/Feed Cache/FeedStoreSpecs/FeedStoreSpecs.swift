//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Apple on 22/01/23.
//

import Foundation

protocol FeedStoreSpecs {
    func test_load_deliversEmptyOnEmptyCache()
    func test_load_hasNoSideEffectOnEmptyCache()
    func test_load_deliversFoundValuesOnNonEmptyCache()
    func test_load_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCachedValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableLoadFeedStoreSpecs: FeedStoreSpecs {
    func test_load_deliversFailureOnLoadError()
    func test_load_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableLoadFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
