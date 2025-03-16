//
//  NetworkError.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(Int)
    case invalidResponse
    case decodingError
    case noData
    case malformedData
    case emptyData
    case serverError
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please check the endpoint."
        case .requestFailed(let statusCode):
            return "Network request failed with status code: \(statusCode)"
        case .invalidResponse:
            return "Invalid response from the server."
        case .decodingError:
            return "Failed to process data from the server."
        case .noData:
            return "No data received from the server."
        case .malformedData:
            return "The data received is not in the expected format."
        case .emptyData:
            return "No recipes are currently available."
        case .serverError:
            return "Server error occurred.\nPlease try again later."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

enum ImageLoadingError: Error {
    case downloadFailed
    case cacheWriteFailed
    case cacheReadFailed
    case invalidData
}
