//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Apple on 05/02/23.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageDataLoader?
    private var tableModal = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var cellControllers = [IndexPath: FeedImageCellController]()
        
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModal = feed
        }
        tableView.prefetchDataSource = self
        
        refreshController?.refresh()
    }
        
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModal.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellConrollers(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).prefetch()
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let cellModal = tableModal[indexPath.row]
        let cellController = FeedImageCellController(model: cellModal, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellConrollers)
    }
    
    private func removeCellConrollers(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
