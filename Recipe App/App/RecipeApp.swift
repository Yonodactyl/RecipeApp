//
//  Recipe_AppApp.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import SwiftUI

@main
struct RecipeApp: App {
    
    @StateObject var recipeListViewModel = RecipeListViewModel()
    
    var body: some Scene {
        WindowGroup {
            RecipeListView(viewModel: recipeListViewModel)
        }
    }
}
