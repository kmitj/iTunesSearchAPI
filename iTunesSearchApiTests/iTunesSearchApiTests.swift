//
//  iTunesSearchApiTests.swift
//  iTunesSearchApiTests
//
//  Created by km1tj on 22/08/24.
//

import XCTest
@testable import iTunesSearchApi

final class iTunesSearchApiTests: XCTestCase {
    
    
    var networkService: NetworkService!

    override func setUp() {
        super.setUp()
        self.networkService = NetworkService()
    }
    
    override func tearDown() {
        self.networkService = nil
        super.tearDown()
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
    func testSearchEndpointURL() {
        let endpoint = APIEndpoint<SearchResult>.search(term: "Michael Jackson", media: .music, limit: 10)
        let expectedURL = "https://itunes.apple.com/search?term=Michael%20Jackson&media=music&limit=10"
        do {
            let urlRequest = try endpoint.asURLRequest()
            XCTAssertEqual(urlRequest.url?.absoluteString, expectedURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLookupArtistInfoEndpointURL() {
        let endpoint = APIEndpoint<LookupResult>.lookupArtistInfo(id: 12345)
        let expectedURL = "https://itunes.apple.com/lookup?id=12345"
        do {
            let urlRequest = try endpoint.asURLRequest()
            XCTAssertEqual(urlRequest.url?.absoluteString, expectedURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLookupArtistWorksEndpointURLWithAMGId() {
        let endpoint = APIEndpoint<LookupResult>.lookupArtistWorks(id: 4321, amgId: 1234, entity: "album", limit: 5)
        let expectedURL = "https://itunes.apple.com/lookup?amgArtistId=1234&entity=album&limit=5&sort=recent"
        do {
            let urlRequest = try endpoint.asURLRequest()
            XCTAssertEqual(urlRequest.url?.absoluteString, expectedURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNetworkErrorHandling() {
        let expectation = self.expectation(description: "Handles network error correctly")
        let endpoint = APIEndpoint<SearchResult>.search(term: "Michael", media: .music, limit: 10)
        let mockSession = MockURLSession(data: nil, response: nil, error: NetworkError.timeout)
        self.networkService = NetworkService(session: mockSession)
        self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to network error, but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestTimeout() {
        let expectation = self.expectation(description: "Handles request timeout correctly")
        let endpoint = APIEndpoint<SearchResult>.search(term: "Michael", media: .music, limit: 10)
        let mockSession = MockURLSession(data: nil, response: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil))
        let networkService = NetworkService(session: mockSession)
        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to timeout, but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class MockURLSession: URLSession {
    var cachedUrl: URL?
    private let mockDataTask: MockURLSessionDataTask
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.mockData = data
        self.mockResponse = response
        self.mockError = error
        self.mockDataTask = MockURLSessionDataTask()
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.mockDataTask.completionHandler = {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
        return mockDataTask
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.cachedUrl = url
        self.mockDataTask.completionHandler = {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
        return mockDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
   
    var completionHandler: (() -> Void)?
        
    override func resume() {
        completionHandler?()
    }
}
