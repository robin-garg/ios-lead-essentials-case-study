//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Apple on 20/04/22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
     
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            // Later we can parse error type and pass error accordingly
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map (_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, response)
            return .success(items.toModals())
        } catch {
            return .failure(error)
        }
    }
}
            
private extension Array where Element == RemoteFeedItem {
    func toModals() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
