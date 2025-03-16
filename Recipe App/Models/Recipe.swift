//
//  Recipe.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import Foundation

struct Recipe: Identifiable, Decodable, Equatable {
    let id: UUID
    let name: String
    let cuisine: String
    let photoURLLarge: String?
    let photoURLSmall: String?
    let sourceURL: String?
    let youtubeURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name, cuisine
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case id = "uuid"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        cuisine = try container.decode(String.self, forKey: .cuisine)
        
        let uuidString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: uuidString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "Invalid UUID string: \(uuidString)"
            )
        }
        id = uuid
        
        photoURLLarge = try container.decodeIfPresent(String.self, forKey: .photoURLLarge)
        photoURLSmall = try container.decodeIfPresent(String.self, forKey: .photoURLSmall)
        sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        youtubeURL = try container.decodeIfPresent(String.self, forKey: .youtubeURL)
    }
    
    init(id: UUID, name: String, cuisine: String, photoURLLarge: String? = nil,
         photoURLSmall: String? = nil, sourceURL: String? = nil, youtubeURL: String? = nil) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.photoURLLarge = photoURLLarge
        self.photoURLSmall = photoURLSmall
        self.sourceURL = sourceURL
        self.youtubeURL = youtubeURL
    }
    
    init(id: UUID = UUID(), name: String, cuisine: String, localImageName: String,
         sourceURL: String? = nil, youtubeURL: String? = nil) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.photoURLLarge = localImageName
        self.photoURLSmall = localImageName
        self.sourceURL = sourceURL
        self.youtubeURL = youtubeURL
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

struct RecipeResponse: Decodable {
    let recipes: [Recipe]
}
