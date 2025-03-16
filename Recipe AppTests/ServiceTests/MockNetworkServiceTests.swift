//
//  MockNetworkServiceTests.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/16/25.
//


import XCTest
@testable import Recipe_App

final class MockNetworkServiceTests: XCTestCase {
    
    var mockService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    func testFetchRecipesSuccess() async throws {
        // Arrange
        mockService.setupMockRecipes()
        mockService.shouldSucceed = true
        mockService.shouldReturnEmptyData = false
        
        // Act
        let recipes = try await mockService.fetchRecipes()
        
        // Assert
        XCTAssertTrue(mockService.fetchRecipesCalled)
        XCTAssertEqual(recipes.count, 3)
        XCTAssertEqual(recipes[0].name, "Pasta Carbonara")
        XCTAssertEqual(recipes[1].name, "Chicken Curry")
        XCTAssertEqual(recipes[2].name, "Tacos")
    }
    
    func testFetchRecipesFailure() async {
        // Arrange
        mockService.shouldSucceed = false
        
        // Act & Assert
        do {
            _ = try await mockService.fetchRecipes()
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertTrue(mockService.fetchRecipesCalled)
            XCTAssertEqual(error as? NetworkError, NetworkError.unknown)
        }
    }
    
    func testFetchRecipesEmptyData() async throws {
        // Arrange
        mockService.shouldReturnEmptyData = true
        
        // Act
        let recipes = try await mockService.fetchRecipes()
        
        // Assert
        XCTAssertTrue(mockService.fetchRecipesCalled)
        XCTAssertTrue(recipes.isEmpty)
    }
    
    func testSetupMockRecipes() {
        // Arrange & Act
        mockService.setupMockRecipes()
        
        // Assert
        XCTAssertEqual(mockService.mockRecipes.count, 3)
        
        let recipe1 = mockService.mockRecipes[0]
        XCTAssertEqual(recipe1.id, UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"))
        XCTAssertEqual(recipe1.name, "Pasta Carbonara")
        XCTAssertEqual(recipe1.cuisine, "Italian")
        XCTAssertEqual(recipe1.photoURLLarge, "https://example.com/pasta-large.jpg")
        XCTAssertEqual(recipe1.photoURLSmall, "https://example.com/pasta-small.jpg")
        XCTAssertEqual(recipe1.sourceURL, "https://example.com/pasta-recipe")
        XCTAssertEqual(recipe1.youtubeURL, "https://youtube.com/pasta")
        
        let recipe2 = mockService.mockRecipes[1]
        XCTAssertEqual(recipe2.id, UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5A"))
        XCTAssertEqual(recipe2.name, "Chicken Curry")
        XCTAssertEqual(recipe2.cuisine, "Indian")
        XCTAssertEqual(recipe2.photoURLLarge, "https://example.com/curry-large.jpg")
        XCTAssertEqual(recipe2.photoURLSmall, "https://example.com/curry-small.jpg")
        XCTAssertEqual(recipe2.sourceURL, "https://example.com/curry-recipe")
        XCTAssertNil(recipe2.youtubeURL)
        
        let recipe3 = mockService.mockRecipes[2]
        XCTAssertEqual(recipe3.id, UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5B"))
        XCTAssertEqual(recipe3.name, "Tacos")
        XCTAssertEqual(recipe3.cuisine, "Mexican")
        XCTAssertEqual(recipe3.photoURLLarge, "https://example.com/tacos-large.jpg")
        XCTAssertEqual(recipe3.photoURLSmall, "https://example.com/tacos-small.jpg")
        XCTAssertNil(recipe3.sourceURL)
        XCTAssertNil(recipe3.youtubeURL)
    }
}
