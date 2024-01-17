//
//  Backup.swift
//  EssentialFeed
//
//  Created by Netsmartz on 17/01/24.
//

import Foundation

/* //
 //  FeedImageDataLoaderWithFallbackCompositeTests.swift
 //  EssentialAppTests
 //
 //  Created by Netsmartz on 16/01/24.
 //

 import XCTest
 import EssentialFeed

 class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
     
     init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {

     }
     
     private class TaskWrapper: FeedImageDataLoaderTask {
         func cancel() {
             
         }
     }
     
     func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
         return TaskWrapper()
     }
 }

 class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
     func test_init_doesNotLoadImageData() {
         
     }
     
     func test_loadImageData_deliversPrimaryResultOnPrimaryLoaderSuccess() {
         let primaryImageData = anyImageData()
         let fallbackImageData = anyImageData()
         
         let url = anyURL()
         let sut = makeSUT(primaryResult: .success(primaryImageData), fallbackResult: .success(fallbackImageData))
         
         let exp = expectation(description: "Wait for load completion")
         _ = sut.loadImageData(from: url) { result in
             switch result {
             case let .success(receivedData):
                 XCTAssertEqual(receivedData, primaryImageData)
             case .failure:
                 XCTFail("Expected successful load image data, got \(result) instead")
             }
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
     }
     
     // MARK: - Helpers
     private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoaderWithFallbackComposite {
         let primaryLoader = LoaderStub(result: primaryResult)
         let fallbackLoader = LoaderStub(result: fallbackResult)
         let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
         trackForMemoryLeak(primaryLoader, file: file, line: line)
         trackForMemoryLeak(fallbackLoader, file: file, line: line)
         trackForMemoryLeak(sut, file: file, line: line)
         return sut
     }
     
     private class LoaderStub: FeedImageDataLoader {
         private var result: FeedImageDataLoader.Result
         
         init(result: FeedImageDataLoader.Result) {
             self.result = result
         }
         
         private class TaskWrapper: FeedImageDataLoaderTask {
             func cancel() {
                 
             }
         }
         
         func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
             completion(result)
             return TaskWrapper()
         }
     }
     
     private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
         // Teardown block will be called after each an every test executed.
         // So instance should be nil here.
         addTeardownBlock { [weak instance] in
             XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
         }
     }
     
     private func anyURL() -> URL {
         return URL(string: "https://any-url.com")!
     }
     
     private func anyImageData() -> Data {
         return UIImage.make(withColor: UIColor.red).pngData()!
     }
 }

 extension UIImage {
     static func make(withColor color: UIColor) -> UIImage {
         let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
         
         let format = UIGraphicsImageRendererFormat()
         format.scale = 1

         return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
             color.setFill()
             rendererContext.fill(rect)
         }
     }
 }
 */
