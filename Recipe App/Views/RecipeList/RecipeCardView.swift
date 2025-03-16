//
//  RecipeCardView.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//
import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let isFeatureCard: Bool
    
    private let imageCacheService: ImageCacheServiceProtocol
    
    init(
        recipe: Recipe,
        isFeatureCard: Bool = false,
        imageCacheService: ImageCacheServiceProtocol = ImageCacheService()
    ) {
        self.recipe = recipe
        self.isFeatureCard = isFeatureCard
        self.imageCacheService = imageCacheService
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CachedAsyncImage(
                urlString: recipe.photoURLLarge ?? recipe.photoURLSmall,
                imageCacheService: imageCacheService
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: isFeatureCard ? 250 : 160,
                        height: isFeatureCard ? 250 : 160
                    )
            }
            .frame(
                width: isFeatureCard ? 250 : 160,
                height: isFeatureCard ? 250 : 160
            )
            .clipShape(RoundedRectangle(cornerRadius: isFeatureCard ? 8 : 12))
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
            
            Text(recipe.name)
                .font(isFeatureCard ? .headline : .subheadline)
                .fontWeight(isFeatureCard ? .bold : .semibold)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: isFeatureCard ? 250 : 160, alignment: .topLeading)
    }
}

struct RecipeCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRecipe = Recipe(
            name: "Margharita Pizza",
            cuisine: "Italian",
            localImageName: "recipe1",
            sourceURL: "https://example.com/recipe",
            youtubeURL: "https://youtube.com/watch?v=example"
        )
        
        Group {
            RecipeCardView(recipe: sampleRecipe)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Standard Card")
            
            RecipeCardView(recipe: sampleRecipe, isFeatureCard: true)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Feature Card")
        }
    }
}
