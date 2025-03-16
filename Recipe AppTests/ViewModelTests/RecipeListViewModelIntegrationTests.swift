//
//  RecipeListViewModelIntegrationTests.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//


import XCTest
@testable import Recipe_App

@MainActor
final class RecipeListViewModelIntegrationTests: XCTestCase {
    
    var viewModel: RecipeListViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockNetworkService.setupMockRecipes()
        viewModel = RecipeListViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testRecipeListInitialFetch() async {
        // Arrange
        
        // Act
        await viewModel.fetchRecipes()
        
        // Assert
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
        
        if case .loaded(let recipes) = viewModel.state {
            XCTAssertEqual(recipes.count, 3)
        } else {
            XCTFail("Expected .loaded state, got \(viewModel.state)")
        }
        
        XCTAssertNotNil(viewModel.categorizedRecipes)
        XCTAssertFalse(viewModel.categorizedRecipes?.isEmpty ?? true)
    }
    
    func testRecipeListRefresh() async {
        // Arrange
        await viewModel.fetchRecipes()
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
        mockNetworkService.fetchRecipesCalled = false
        
        // Act
        await viewModel.refreshRecipes()
        
        // Assert
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
    }
    
    func testRecipeListErrorHandling() async {
        // Arrange
        mockNetworkService.shouldSucceed = false
        
        // Act
        await viewModel.fetchRecipes()
        
        // Assert
        if case .error(let error) = viewModel.state {
            XCTAssertEqual(error, .unknown)
        } else {
            XCTFail("Expected .error state, got \(viewModel.state)")
        }
        
        XCTAssertNotNil(viewModel.categorizedRecipes)
        XCTAssertTrue(viewModel.categorizedRecipes?.isEmpty ?? false)
    }
    
    func testRecipeListEmptyResponse() async {
        // Arrange
        mockNetworkService.shouldReturnEmptyData = true
        
        // Act
        await viewModel.fetchRecipes()
        
        // Assert
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertNotNil(viewModel.categorizedRecipes)
        XCTAssertTrue(viewModel.categorizedRecipes?.isEmpty ?? false)
    }
    
    func testRecipeListFilterAndSearch() async {
        // Arrange
        await viewModel.fetchRecipes()
        viewModel.searchText = "Pasta"
        
        // Act
        let filteredCategorized = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        let allFilteredRecipes = filteredCategorized.highlightedRecipes +
                                filteredCategorized.regularCuisines.flatMap { $0.recipes }
        
        let containsPasta = allFilteredRecipes.contains { $0.name == "Pasta Carbonara" }
        let containsChicken = allFilteredRecipes.contains { $0.name == "Chicken Curry" }
        
        XCTAssertTrue(containsPasta)
        XCTAssertFalse(containsChicken)
        XCTAssertFalse(filteredCategorized.isEmpty)
        
        // Arrange
        viewModel.searchText = "NonExistentDish"
        
        // Act
        let emptyResult = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        XCTAssertTrue(emptyResult.isEmpty)
        
        // Arrange
        viewModel.searchText = ""
        
        // Act
        let fullResult = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        XCTAssertFalse(fullResult.isEmpty)
        let totalRecipeCount = fullResult.highlightedRecipes.count +
                              fullResult.regularCuisines.flatMap { $0.recipes }.count
        XCTAssertEqual(totalRecipeCount, 3)
    }
}
