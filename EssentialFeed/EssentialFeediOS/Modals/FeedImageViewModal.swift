//
//  FeedImageViewModal.swift
//  EssentialFeediOS
//
//  Created by Apple on 12/03/23.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var location: String? {
        return model.location
    }
    
    var description: String? {
        return model.description
    }
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onLoadFeedImage: ((UIImage?) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                self?.onLoadFeedImage?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)
            }
            self?.onImageLoadingStateChange?(false)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
