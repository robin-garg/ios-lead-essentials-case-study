//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Netsmartz on 16/01/24.
//

import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        self.primary.load { result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self.fallback.load(completion: completion)
            }
        }
    }
}
