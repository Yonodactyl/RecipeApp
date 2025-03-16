//
//  SampleData.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation

extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(name: "Margherita Pizza with a little longer of a name", cuisine: "Italian", localImageName: "recipe1"),
        Recipe(name: "Spaghetti Carbonara", cuisine: "Italian", localImageName: "recipe2"),
        Recipe(name: "Tiramisu", cuisine: "Italian", localImageName: "recipe3"),
        
        Recipe(name: "Beef Tacos", cuisine: "Mexican", localImageName: "recipe4"),
        Recipe(name: "Cheeseburger", cuisine: "American", localImageName: "recipe5"),
    ]
}
