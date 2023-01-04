//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Apple on 01/01/23.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (modals: [FeedImage], local: [LocalFeedImage]) {
    let modals = [uniqueImage(), uniqueImage()]
    let local = modals.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (modals, local)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
