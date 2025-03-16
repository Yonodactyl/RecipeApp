//
//  RecipeListView.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import SwiftUI

struct RecipeListView: View {
    enum Field: Hashable {
        case search
    }
    
    @ObservedObject private var viewModel: RecipeListViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isSearching = false
    
    @FocusState private var focused: Field?
    
    init(viewModel: RecipeListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Recipes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.serif)
                    }
                    
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        
                        if case .loaded = viewModel.state {
                            Button(action: {
                                withAnimation(.bouncy) {
                                    viewModel.searchText = ""
                                    isSearching.toggle()
                                    focused = isSearching ? .search : nil
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .font(.headline)
                            }
                            .tint(isSearching ? .secondary : .primary)
                        }
                    }
                }
                .toolbarBackground(colorScheme == .dark ? Color.black : Color.white, for: .navigationBar)
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.fetchRecipes()
                    }
                }
            
        }
    }
    
    private var searchBarView: some View {
        TextField("", text: $viewModel.searchText.animation(.easeInOut), prompt: Text("Search recipes"))
            .focused($focused, equals: .search)
            .padding()
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
            
        case .loaded:
            let categorized = viewModel.getFilteredCategorizedRecipes()
            
            categorizedRecipesList(categorized)
                .refreshable {
                    await viewModel.refreshRecipes()
                }
                .background {
                    if categorized.isEmpty {
                        emptySearchResultsView
                    }
                }
                .animation(.smooth, value: categorized.isEmpty)
            
        case .empty:
            EmptyStateView(message: "No recipes available") {
                refresh()
            }
            
        case .error(let error):
            ErrorView(error: error) {
                refresh()
            }
        }
    }
    
    private var emptySearchResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No recipes match your search")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func categorizedRecipesList(_ categorized: CategorizedRecipes) -> some View {
        VStack (alignment: .leading) {
            searchBarView
                .frame(height: isSearching ? nil : 0)
                .opacity(isSearching ? 1 : 0)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !categorized.highlightedCuisine.isEmpty && !categorized.highlightedRecipes.isEmpty {
                        CuisineSectionView(
                            cuisineTitle: categorized.highlightedCuisine,
                            recipes: categorized.highlightedRecipes,
                            isFeatureSection: true,
                            isHighlighted: true
                        )
                        
                        if !categorized.regularCuisines.isEmpty {
                            Divider()
                                .overlay {
                                    Color(.systemGray4)
                                }
                                .padding(.horizontal, 16)
                        }
                    }
                    
                    if !categorized.regularCuisines.isEmpty {
                        ForEach(categorized.regularCuisines.indices, id: \.self) { index in
                            let (cuisine, cuisineRecipes) = categorized.regularCuisines[index]
                            
                            if !cuisineRecipes.isEmpty {
                                CuisineSectionView(
                                    cuisineTitle: cuisine,
                                    recipes: cuisineRecipes,
                                    isFeatureSection: false,
                                    isHighlighted: false
                                )
                                
                                if index < categorized.regularCuisines.count - 1 {
                                    Divider()
                                        .overlay {
                                            Color(.systemGray4)
                                        }
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
                .frame(minWidth: 200, maxWidth: .infinity)
                .padding(.vertical, 8)
                .opacity(categorized.isEmpty ? 0 : 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func refresh() {
        Task {
            await viewModel.refreshRecipes()
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = RecipeListViewModel(networkService: MockNetworkService())
        
        RecipeListView(viewModel: mockViewModel)
            .onAppear {
                Task {
                    await mockViewModel.fetchRecipes()
                }
            }
    }
}
