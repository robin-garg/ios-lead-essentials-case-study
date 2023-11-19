//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Netsmartz on 19/11/23.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        var requestObserver: ((URLRequest) -> Void)?
    }
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub }}
        set { queue.sync { _stub = newValue }}
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.stub")
    
    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        stub.requestObserver?(request)
    }
    
    override func stopLoading() { }
}
