//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Netsmartz on 09/11/23.
//

import UIKit

extension UIRefreshControl {
    func update(_ isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
