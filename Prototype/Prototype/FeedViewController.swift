//
//  FeedViewController.swift
//  Prototype
//
//  Created by Apple on 03/02/23.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.prototypeFeed
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let modal = feed[indexPath.row]
        // Configure the cell...
        cell.configure(with: modal)
        return cell
    }
}

extension FeedImageCell {
    func configure(with modal: FeedImageViewModel) {
        locationLabel.text = modal.location
        locationConatiner.isHidden = modal.location == nil
        
        fadeIn(UIImage(named: modal.imageName))
        
        descriptionLabel.text = modal.description
        descriptionLabel.isHidden = modal.description == nil
    }
}
