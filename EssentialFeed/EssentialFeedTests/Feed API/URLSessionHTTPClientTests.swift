//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 09/05/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    // Called every time before a test method executed
    override class func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    // Called every time after a test method executed
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // We can use same observeRequest behaviour for checking other methods
    // like POST or request body or query parameters of requests etc
    func test_getFromURL_performGETRequestFromURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")

        }
        makeSUT().get(from: url) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let expectedError = anyNSError()
        let error = resultErrorFor((data: nil, response: nil, error: expectedError)) as NSError?
        
        if let receivedError = error {
            XCTAssertEqual(receivedError.domain, expectedError.domain)
            XCTAssertEqual(receivedError.code, expectedError.code)
        }
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValue = resultValueFor((data: anyData(), response: response, error: nil))

        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let receivedValue = resultValueFor((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: ((HTTPClientTask) -> Void) = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let receivedResult = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch receivedResult {
            case let .failure(error):
                return error
            default:
                XCTFail("Expected failure got \(receivedResult) instead", file: file, line: line)
                return nil
        }
    }

    private func resultValueFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let receivedResult = resultFor(values, file: file, line: line)
        switch receivedResult {
            case let .success((data, response)):
                return (data, response)
            default:
                XCTFail("Expected success got \(receivedResult) instead", file: file, line: line)
                return nil
        }
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: ((HTTPClientTask) -> Void) = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
                
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
        
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            URLProtocolStub.requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
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
        }
        
        override func stopLoading() { }
    }
}
