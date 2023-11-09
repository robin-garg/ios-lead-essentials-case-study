//
//  FeedErrorViewModal.swift
//  EssentialFeediOS
//
//  Created by Netsmartz on 09/11/23.
//

struct FeedErrorViewModal {
    let message: String?
    
    static var noError: FeedErrorViewModal {
        return FeedErrorViewModal(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModal {
        return FeedErrorViewModal(message: message)
    }
}
