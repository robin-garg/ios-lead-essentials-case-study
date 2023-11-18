//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Apple on 01/01/23.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}
