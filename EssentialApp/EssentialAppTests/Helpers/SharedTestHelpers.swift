//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Netsmartz on 19/01/24.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyData() -> Data {
    return Data("any data".utf8)
}
