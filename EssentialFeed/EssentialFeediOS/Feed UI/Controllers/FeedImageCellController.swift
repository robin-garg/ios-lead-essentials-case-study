//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Apple on 11/03/23.
//

import UIKit

final class FeedImageCellController {
    private var viewModal: FeedImageViewModel<UIImage>
    
    init(viewModal: FeedImageViewModel<UIImage>) {
        self.viewModal = viewModal
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModal.loadImageData()
        return cell
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = !viewModal.hasLocation
        cell.locationLabel.text = viewModal.location
        cell.descriptionLabel.text = viewModal.description
        cell.onRetry = viewModal.loadImageData
        
        viewModal.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }

        viewModal.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModal.onLoadFeedImage = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        return cell
    }
    
    func prefetch() {
        viewModal.loadImageData()
    }
    
    func cancelLoad() {
        viewModal.cancelImageDataLoad()
    }
}
