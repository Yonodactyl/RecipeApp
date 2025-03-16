//
//  RecipeListViewModel.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation
import SwiftUI

enum RecipeListState: Equatable {
    case idle
    case loading
    case loaded([Recipe])
    case empty
    case error(NetworkError)
}

struct CategorizedRecipes: Equatable {
    let highlightedCuisine: String
    let highlightedRecipes: [Recipe]
    let regularCuisines: [(cuisine: String, recipes: [Recipe])]
    let isEmpty: Bool
    
    static func == (lhs: CategorizedRecipes, rhs: CategorizedRecipes) -> Bool {
        return lhs.highlightedCuisine == rhs.highlightedCuisine &&
               lhs.highlightedRecipes == rhs.highlightedRecipes &&
               lhs.regularCuisines.count == rhs.regularCuisines.count &&
               zip(lhs.regularCuisines, rhs.regularCuisines).allSatisfy { lhsPair, rhsPair in
                   return lhsPair.cuisine == rhsPair.cuisine &&
                          lhsPair.recipes == rhsPair.recipes
               } &&
               lhs.isEmpty == rhs.isEmpty
    }
}

@MainActor
class RecipeListViewModel: ObservableObject {
    @Published private(set) var state: RecipeListState = .idle
    @Published var searchText = ""
    
    @Published private(set) var categorizedRecipes: CategorizedRecipes?
    
    private let networkService: NetworkServiceProtocol
    private var allRecipes: [Recipe] = []
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchRecipes() async {
        if case .loading = state { return }
        
        state = .loading
        
        do {
            let recipes = try await networkService.fetchRecipes()
            
            if recipes.isEmpty {
                state = .empty
                categorizedRecipes = CategorizedRecipes(
                    highlightedCuisine: "",
                    highlightedRecipes: [],
                    regularCuisines: [],
                    isEmpty: true
                )
            } else {
                allRecipes = recipes
                state = .loaded(recipes)
                
                if categorizedRecipes == nil {
                    createCategorizedRecipes(from: recipes)
                }
            }
        } catch let error as NetworkError {
            switch error {
            case .emptyData:
                state = .empty
            default:
                state = .error(error)
            }
            categorizedRecipes = CategorizedRecipes(
                highlightedCuisine: "",
                highlightedRecipes: [],
                regularCuisines: [],
                isEmpty: true
            )
        } catch {
            state = .error(.unknown)
            categorizedRecipes = CategorizedRecipes(
                highlightedCuisine: "",
                highlightedRecipes: [],
                regularCuisines: [],
                isEmpty: true
            )
        }
    }
    
    func refreshRecipes() async {
        categorizedRecipes = nil
        await fetchRecipes()
    }
    
    func filterRecipes() -> [Recipe] {
        guard !searchText.isEmpty else { return allRecipes }
        
        return allRecipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText) ||
            recipe.cuisine.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func createCategorizedRecipes(from recipes: [Recipe]) {
        if recipes.isEmpty {
            categorizedRecipes = CategorizedRecipes(
                highlightedCuisine: "",
                highlightedRecipes: [],
                regularCuisines: [],
                isEmpty: true
            )
            return
        }
        
        let groupedRecipes = Dictionary(grouping: recipes) { $0.cuisine }
            .sorted { $0.key < $1.key }
        
        let randomIndex = Int.random(in: 0..<groupedRecipes.count)
        
        let (highlightedCuisine, highlightedRecipes) = groupedRecipes[randomIndex]
        
        var regularCuisines = groupedRecipes
        regularCuisines.remove(at: randomIndex)
        
        categorizedRecipes = CategorizedRecipes(
            highlightedCuisine: highlightedCuisine,
            highlightedRecipes: highlightedRecipes,
            regularCuisines: regularCuisines.map { ($0.key, $0.value) },
            isEmpty: false
        )
    }
    
    func getFilteredCategorizedRecipes() -> CategorizedRecipes {
        guard let categorized = categorizedRecipes else {
            return CategorizedRecipes(
                highlightedCuisine: "",
                highlightedRecipes: [],
                regularCuisines: [],
                isEmpty: true
            )
        }
        
        if searchText.isEmpty {
            return categorized
        }
        
        let filteredHighlightedRecipes = categorized.highlightedRecipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText) ||
            recipe.cuisine.localizedCaseInsensitiveContains(searchText)
        }
        
        let filteredRegularCuisines = categorized.regularCuisines.compactMap { cuisine, recipes in
            let filteredRecipes = recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.cuisine.localizedCaseInsensitiveContains(searchText)
            }
            
            return filteredRecipes.isEmpty ? nil : (cuisine: cuisine, recipes: filteredRecipes)
        }
        
        if filteredHighlightedRecipes.isEmpty && filteredRegularCuisines.isEmpty {
            return CategorizedRecipes(
                highlightedCuisine: "",
                highlightedRecipes: [],
                regularCuisines: [],
                isEmpty: true
            )
        }
        
        let finalHighlightedCuisine = filteredHighlightedRecipes.isEmpty ? "" : categorized.highlightedCuisine
        
        return CategorizedRecipes(
            highlightedCuisine: finalHighlightedCuisine,
            highlightedRecipes: filteredHighlightedRecipes,
            regularCuisines: filteredRegularCuisines,
            isEmpty: false
        )
    }
}
