//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Apple on 05/02/23.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModal = [FeedImage]()
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.tableModal = feed
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            case .failure: break
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModal.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModal = tableModal[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModal.location == nil)
        cell.locationLabel.text = cellModal.location
        cell.descriptionLabel.text = cellModal.description
        return cell
    }
}
