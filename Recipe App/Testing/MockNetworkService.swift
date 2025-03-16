//
//  MockNetworkService.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation

class MockNetworkService: NetworkServiceProtocol {
    enum MockError: Error {
        case forcedError
    }
    
    var shouldSucceed = true
    var shouldReturnEmptyData = false
    var mockRecipes: [Recipe] = []
    var fetchRecipesCalled = false
    
    func fetchRecipes() async throws -> [Recipe] {
        fetchRecipesCalled = true
        
        if !shouldSucceed {
            throw NetworkError.unknown
        }
        
        if shouldReturnEmptyData {
            return []
        }
        
        return mockRecipes
    }
    
    func setupMockRecipes() {
        mockRecipes = [
            Recipe(
                id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                name: "Pasta Carbonara",
                cuisine: "Italian",
                photoURLLarge: "https://example.com/pasta-large.jpg",
                photoURLSmall: "https://example.com/pasta-small.jpg",
                sourceURL: "https://example.com/pasta-recipe",
                youtubeURL: "https://youtube.com/pasta"
            ),
            Recipe(
                id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5A")!,
                name: "Chicken Curry",
                cuisine: "Indian",
                photoURLLarge: "https://example.com/curry-large.jpg",
                photoURLSmall: "https://example.com/curry-small.jpg",
                sourceURL: "https://example.com/curry-recipe",
                youtubeURL: nil
            ),
            Recipe(
                id: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5B")!,
                name: "Tacos",
                cuisine: "Mexican",
                photoURLLarge: "https://example.com/tacos-large.jpg",
                photoURLSmall: "https://example.com/tacos-small.jpg",
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
    }
}

