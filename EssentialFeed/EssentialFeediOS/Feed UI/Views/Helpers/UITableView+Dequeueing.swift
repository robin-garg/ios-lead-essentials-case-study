//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Apple on 05/11/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T:UITableViewCell>() -> T {
        let identifire = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifire) as! T
    }
}
