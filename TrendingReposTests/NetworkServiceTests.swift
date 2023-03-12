//
//  NetworkServiceTests.swift
//  TrendingReposTests
//
//  Created by Saad Umar on 3/11/23.
//
import XCTest
@testable import TrendingRepos

final class NetworkServiceTests: XCTestCase {
    ///To establish NetworkService is working as expected under green network conditions, testing red network conditions not required since NetworkService().get method is throwing
    func test_givenValidResourceExists_dataIsReturned() async throws {
        let service = NetworkService()
        let expectation = self.expectation(description: "resource")
        var resourceData: Data?
        var resourceError: Error?
        let request = MockRequest(url: URL(string: "https://www.google.com")!)
        switch try await service.get(request: request) {
        case .success(let data):
            resourceData = data
        case .failure(let error):
            resourceError = error
            
        }
        expectation.fulfill()
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertNil(resourceError)
        XCTAssertNotNil(resourceData)
    }
}

fileprivate struct MockRequest: Request {
    var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    var url: URL
}
