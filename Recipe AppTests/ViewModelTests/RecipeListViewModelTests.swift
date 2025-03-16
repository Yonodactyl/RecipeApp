//
//  RecipeListViewModelTests.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//


import XCTest
@testable import Recipe_App

@MainActor
final class RecipeListViewModelTests: XCTestCase {
    
    var viewModel: RecipeListViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = RecipeListViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.categorizedRecipes)
    }
    
    func testFetchRecipesSuccess() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        mockNetworkService.shouldSucceed = true
        
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
    
    func testFetchRecipesEmpty() async {
        // Arrange
        mockNetworkService.shouldReturnEmptyData = true
        
        // Act
        await viewModel.fetchRecipes()
        
        // Assert
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertNotNil(viewModel.categorizedRecipes)
        XCTAssertTrue(viewModel.categorizedRecipes?.isEmpty ?? false)
    }
    
    func testFetchRecipesError() async {
        // Arrange
        mockNetworkService.shouldSucceed = false
        
        // Act
        await viewModel.fetchRecipes()
        
        // Assert
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
        
        if case .error(let error) = viewModel.state {
            XCTAssertEqual(error, .unknown)
        } else {
            XCTFail("Expected .error state, got \(viewModel.state)")
        }
        
        XCTAssertNotNil(viewModel.categorizedRecipes)
        XCTAssertTrue(viewModel.categorizedRecipes?.isEmpty ?? false)
    }
    
    func testFilterRecipesWithNoSearchText() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        await viewModel.fetchRecipes()
        
        // Act
        let filteredRecipes = viewModel.filterRecipes()
        
        // Assert
        XCTAssertEqual(filteredRecipes.count, 3)
    }
    
    func testFilterRecipesWithSearchText() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        await viewModel.fetchRecipes()
        
        // Act
        viewModel.searchText = "Pasta"
        let filteredRecipes = viewModel.filterRecipes()
        
        // Assert
        XCTAssertEqual(filteredRecipes.count, 1)
        XCTAssertEqual(filteredRecipes.first?.name, "Pasta Carbonara")
        
        // Arrange
        viewModel.searchText = "Italian"
        
        // Act
        let filteredByCuisine = viewModel.filterRecipes()
        
        // Assert
        XCTAssertEqual(filteredByCuisine.count, 1)
        XCTAssertEqual(filteredByCuisine.first?.cuisine, "Italian")
    }
    
    func testFilterRecipesWithPartialMatch() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        await viewModel.fetchRecipes()
        
        // Act
        viewModel.searchText = "Chick"
        let filteredRecipes = viewModel.filterRecipes()
        
        // Assert
        XCTAssertEqual(filteredRecipes.count, 1)
        XCTAssertEqual(filteredRecipes.first?.name, "Chicken Curry")
        
        // Arrange
        viewModel.searchText = "meXiCaN"
        
        // Act
        let caseInsensitiveResults = viewModel.filterRecipes()
        
        // Assert
        XCTAssertEqual(caseInsensitiveResults.count, 1)
        XCTAssertEqual(caseInsensitiveResults.first?.cuisine, "Mexican")
    }
    
    func testRefreshRecipes() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        await viewModel.fetchRecipes()
        XCTAssertNotNil(viewModel.categorizedRecipes)
        mockNetworkService.fetchRecipesCalled = false
        
        // Act
        await viewModel.refreshRecipes()
        
        // Assert
        XCTAssertTrue(mockNetworkService.fetchRecipesCalled)
        XCTAssertNotNil(viewModel.categorizedRecipes)
    }
    
    func testGetFilteredCategorizedRecipes() async {
        // Arrange
        mockNetworkService.setupMockRecipes()
        await viewModel.fetchRecipes()
        
        // Act
        let unfilteredCategories = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        XCTAssertFalse(unfilteredCategories.isEmpty)
        
        // Arrange
        viewModel.searchText = "Pasta"
        
        // Act
        let filteredCategories = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        let hasMatchInHighlighted = filteredCategories.highlightedRecipes.contains { $0.name.contains("Pasta") }
        let hasMatchInRegular = filteredCategories.regularCuisines.contains { cuisine, recipes in
            recipes.contains { $0.name.contains("Pasta") }
        }
        XCTAssertTrue(hasMatchInHighlighted || hasMatchInRegular)
        
        // Arrange
        viewModel.searchText = "Non existent recipe"
        
        // Act
        let emptyFilteredCategories = viewModel.getFilteredCategorizedRecipes()
        
        // Assert
        XCTAssertTrue(emptyFilteredCategories.isEmpty)
    }
}
