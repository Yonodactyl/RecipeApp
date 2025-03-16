//
//  CuisineSectionView.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import SwiftUI

struct CuisineSectionView: View {
    let cuisineTitle: String
    let recipes: [Recipe]
    let isFeatureSection: Bool
    let isHighlighted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(cuisineTitle + " Cuisine")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if isHighlighted {
                    Text("Highlighted Cuisine")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 16)
            .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: isFeatureSection ? 16 : 12) {
                    ForEach(recipes) { recipe in
                        RecipeCardView(
                            recipe: recipe,
                            isFeatureCard: isFeatureSection
                        )
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CuisineSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRecipes = [
            Recipe(
                name: "Margherita Pizza",
                cuisine: "Italian",
                localImageName: "recipe1"
            ),
            Recipe(
                name: "Spaghetti Carbonara",
                cuisine: "Italian",
                localImageName: "recipe2"
            ),
            Recipe(
                name: "Tiramisu",
                cuisine: "Dessert",
                localImageName: "recipe3"
            )
        ]
        
        Group {
            CuisineSectionView(
                cuisineTitle: "Italian",
                recipes: sampleRecipes,
                isFeatureSection: true,
                isHighlighted: true
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Feature Section")
            
            CuisineSectionView(
                cuisineTitle: "Italian",
                recipes: sampleRecipes,
                isFeatureSection: false,
                isHighlighted: false
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Regular Section")
        }
    }
}
