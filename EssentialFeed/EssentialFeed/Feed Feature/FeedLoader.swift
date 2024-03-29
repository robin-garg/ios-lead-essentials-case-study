//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Apple on 19/04/22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
