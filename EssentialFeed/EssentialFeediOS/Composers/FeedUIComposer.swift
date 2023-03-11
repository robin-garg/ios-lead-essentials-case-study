//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Apple on 11/03/23.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // Adapter Patteren
    // To convert one type of data to another type to adapt requirement of different dependencies
    // like here Referesh control retrun [FeedImage] and Feed View Controller needs [FeedImageCellController]
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModal = feed.map { model in
                FeedImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
