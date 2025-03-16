//
//  NetworkServiceTests.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import XCTest
@testable import Recipe_App

final class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var mockSession: URLSession!
    let recipesEndpoint = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSessionFactory.createMockSession()
        networkService = NetworkService(session: mockSession)
    }
    
    override func tearDown() {
        MockURLSessionFactory.clearMocks()
        networkService = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchRecipesSuccess() async throws {
        // Arrange
        let jsonData = """
        {
            "recipes": [
                {
                    "uuid": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
                    "name": "Pasta Carbonara",
                    "cuisine": "Italian",
                    "photo_url_large": "https://example.com/pasta-large.jpg",
                    "photo_url_small": "https://example.com/pasta-small.jpg",
                    "source_url": "https://example.com/pasta-recipe",
                    "youtube_url": "https://youtube.com/pasta"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLSessionFactory.setupSuccessResponse(for: recipesEndpoint, with: jsonData)
        
        // Act
        let recipes = try await networkService.fetchRecipes()
        
        // Assert
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].id, UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"))
        XCTAssertEqual(recipes[0].name, "Pasta Carbonara")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
        XCTAssertEqual(recipes[0].photoURLLarge, "https://example.com/pasta-large.jpg")
        XCTAssertEqual(recipes[0].photoURLSmall, "https://example.com/pasta-small.jpg")
        XCTAssertEqual(recipes[0].sourceURL, "https://example.com/pasta-recipe")
        XCTAssertEqual(recipes[0].youtubeURL, "https://youtube.com/pasta")
    }
    
    func testFetchRecipesEmptyData() async {
        // Arrange
        let jsonData = """
        {
            "recipes": []
        }
        """.data(using: .utf8)!
        
        MockURLSessionFactory.setupSuccessResponse(for: recipesEndpoint, with: jsonData)
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch let error as NetworkError {
            XCTAssertTrue(true, "We got an error as expected: \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesMalformedData() async {
        // Arrange
        let jsonData = """
        {
            "recipes": [
                {
                    "uuid": "not-a-valid-uuid",
                    "name": "Pasta Carbonara",
                    "cuisine": "Italian"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLSessionFactory.setupSuccessResponse(for: recipesEndpoint, with: jsonData)
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.malformedData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesMissingRequiredField() async {
        // Arrange
        let jsonData = """
        {
            "recipes": [
                {
                    "uuid": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
                    "name": "Pasta Carbonara"
                }
            ]
        }
        """.data(using: .utf8)!
        
        MockURLSessionFactory.setupSuccessResponse(for: recipesEndpoint, with: jsonData)
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.malformedData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesRequestFailed() async {
        // Arrange
        MockURLSessionFactory.setupInvalidResponse(for: recipesEndpoint, statusCode: 404)
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.requestFailed(404))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesNoData() async {
        // Arrange
        MockURLSessionFactory.setupSuccessResponse(for: recipesEndpoint, with: Data())
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.noData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecipesNetworkError() async {
        // Arrange
        let networkError = URLError(.notConnectedToInternet)
        MockURLSessionFactory.setupErrorResponse(for: recipesEndpoint, with: networkError)
        
        // Act & Assert
        do {
            _ = try await networkService.fetchRecipes()
            XCTFail("Expected error but fetch succeeded")
        } catch {
            XCTAssertTrue(error is URLError)
            let urlError = error as! URLError
            XCTAssertEqual(urlError.code, .notConnectedToInternet)
        }
    }
}
