//
//  MockURLSessionFactory.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation
@testable import Recipe_App

class MockURLSessionFactory {
    static func createMockSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    
    static func setupSuccessResponse(for urlString: String, with data: Data, statusCode: Int = 200) {
        MockURLProtocol.addMock(urlString: urlString, data: data, statusCode: statusCode)
    }
    
    static func setupErrorResponse(for urlString: String, with error: Error) {
        MockURLProtocol.addMock(urlString: urlString, error: error)
    }
    
    static func setupInvalidResponse(for urlString: String, statusCode: Int = 404) {
        MockURLProtocol.addMock(urlString: urlString, data: Data(), statusCode: statusCode)
    }
    
    static func clearMocks() {
        MockURLProtocol.removeAllMocks()
    }
}
