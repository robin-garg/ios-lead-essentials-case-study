//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Apple on 03/01/23.
//

import Foundation

internal final class FeedCachePolicy {
    private static let calender = Calendar(identifier: .gregorian)
    
    private static var maxCachedAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCachedAge = calender.date(byAdding: .day, value: maxCachedAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCachedAge
    }
}
