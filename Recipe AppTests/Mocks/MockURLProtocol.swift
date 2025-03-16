//
//  MockURLProtocol.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation
@testable import Recipe_App

class MockURLProtocol: URLProtocol {
    static var testURLs = [URL: (data: Data?, response: URLResponse?, error: Error?)]()
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            if let (data, response, error) = MockURLProtocol.testURLs[url] {
                if let responseData = data {
                    client?.urlProtocol(self, didLoad: responseData)
                }
                if let responseURL = response {
                    client?.urlProtocol(self, didReceive: responseURL, cacheStoragePolicy: .notAllowed)
                }
                if let responseError = error {
                    client?.urlProtocol(self, didFailWithError: responseError)
                }
            }
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

// MARK: - Helper Method

extension MockURLProtocol {
    
    static func addMock(urlString: String, data: Data? = nil, statusCode: Int = 200, error: Error? = nil) {
        guard let url = URL(string: urlString) else { return }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        
        testURLs[url] = (data, response, error)
    }
    
    static func removeAllMocks() {
        testURLs.removeAll()
    }
}
