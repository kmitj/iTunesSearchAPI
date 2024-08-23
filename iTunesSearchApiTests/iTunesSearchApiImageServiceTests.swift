//
//  iTunesSearchApiImageServiceTests.swift
//  iTunesSearchApiTests
//
//  Created by km1tj on 23/08/24.
//

import XCTest
@testable import iTunesSearchApi

final class iTunesSearchApiImageServiceTests: XCTestCase {

    var imageService: ImageService!

    override func setUp() {
        super.setUp()
        self.imageService = ImageService.instance
    }
    
    override func tearDown() {
        self.imageService = nil
        super.tearDown()
    }
    
    func testImageIsLoadedFromCache() {
        let imageService = ImageService.instance
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        let testImage = UIImage(systemName: "person")!
        imageService.imageCache.setObject(testImage, forKey: imageUrl.absoluteString as NSString)
        let expectation = self.expectation(description: "Image should be loaded from cache")
        imageService.downloadImage(from: imageUrl) { image in
            XCTAssertEqual(image, testImage)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testImageIsDownloadedAndCached() {
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        let testImage = UIImage(systemName: "person")!
        let mockSession = MockURLSession(data: testImage.pngData(), response: nil, error: nil)
        let imageService = ImageService(session: mockSession)
        let expectation = self.expectation(description: "Image should be downloaded and cached")
        imageService.downloadImage(from: imageUrl) { image in
            XCTAssertNotNil(image)
            XCTAssertEqual(imageService.imageCache.object(forKey: imageUrl.absoluteString as NSString), image)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testImageDownloadFailsWithError() {
        let imageUrl = URL(string: "https://example.com/image.jpg")!
        let mockSession = MockURLSession(data: nil, response: nil, error: NetworkError.timeout)
        let imageService = ImageService(session: mockSession)
        let expectation = self.expectation(description: "Image download should fail and return nil")
        imageService.downloadImage(from: imageUrl) { image in
            XCTAssertNil(image)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
