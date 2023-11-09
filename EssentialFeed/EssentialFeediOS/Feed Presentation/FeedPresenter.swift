//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Apple on 14/03/23.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModal: FeedErrorViewModal)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let feedErrorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.feedErrorView = feedErrorView
    }
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "")
    }
    
    private var errorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(FeedErrorViewModal(message: errorMessage))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
