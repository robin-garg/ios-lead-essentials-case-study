//
//  FeedImageViewModal.swift
//  EssentialFeediOS
//
//  Created by Apple on 12/03/23.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}


//final class FeedImageViewModel<Image> {
//    typealias Observer<T> = (T) -> Void
//    
//    private var task: FeedImageDataLoaderTask?
//    private let model: FeedImage
//    private let imageLoader: FeedImageDataLoader
//    private let imageTransformer: (Data) -> Image?
//    
//    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
//        self.model = model
//        self.imageLoader = imageLoader
//        self.imageTransformer = imageTransformer
//    }
//    
//    var location: String? {
//        return model.location
//    }
//    
//    var description: String? {
//        return model.description
//    }
//    
//    var hasLocation: Bool {
//        return location != nil
//    }
//    
//    var onImageLoadingStateChange: Observer<Bool>?
//    var onLoadFeedImage: Observer<Image>?
//    var onShouldRetryImageLoadStateChange: Observer<Bool>?
//    
//    func loadImageData() {
//        onImageLoadingStateChange?(true)
//        onShouldRetryImageLoadStateChange?(false)
//        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
//            self?.handle(result)
//        }
//    }
//    
//    func handle(_ result: FeedImageDataLoader.Result) {
//        if let image = (try? result.get()).flatMap(imageTransformer) {
//            self.onLoadFeedImage?(image)
//        } else {
//            self.onShouldRetryImageLoadStateChange?(true)
//        }
//        self.onImageLoadingStateChange?(false)
//    }
//    
//    func cancelImageDataLoad() {
//        task?.cancel()
//        task = nil
//    }
//}
