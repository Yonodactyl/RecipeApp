//
//  NetworkService.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
}

class NetworkService: NetworkServiceProtocol {
    enum Endpoint {
        static let recipes = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        static let malformedData = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        static let emptyData = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
    }
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let recipeURLString: String
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        recipeURLString: String = Endpoint.recipes
    ) {
        self.session = session
        self.decoder = decoder
        self.recipeURLString = recipeURLString
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: recipeURLString) else {
            throw NetworkError.invalidURL
        }
        
        return try await fetchData(from: url)
    }
    
    private func fetchData(from url: URL) async throws -> [Recipe] {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            
            return recipeResponse.recipes
        } catch {
            if error as? NetworkError == .malformedData {
                throw NetworkError.malformedData
            } else if error as? NetworkError == NetworkError.emptyData {
                throw NetworkError.emptyData
            } else {
                throw NetworkError.unknown
            }
        }
    }
}
