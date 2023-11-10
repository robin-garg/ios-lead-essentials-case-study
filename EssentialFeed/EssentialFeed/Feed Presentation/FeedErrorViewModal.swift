//
//  FeedErrorViewModal.swift
//  EssentialFeed
//
//  Created by Netsmartz on 10/11/23.
//

import Foundation

public struct FeedErrorViewModal {
    public let message: String?
    
    static var noError: FeedErrorViewModal {
        return FeedErrorViewModal(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModal {
        return FeedErrorViewModal(message: message)
    }
}
