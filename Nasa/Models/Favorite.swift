//
//  Favorite.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import Foundation

struct FavoriteModel: Codable {
    let nasaId: String
    let assetLink: String
    let thumbnailLink: String?
    let mediaType: FavoriteType
    let title: String
    let date: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case nasaId, assetLink, mediaType, title, date, description, thumbnailLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nasaId = try container.decode(String.self, forKey: .nasaId)
        assetLink = try container.decode(String.self, forKey: .assetLink)
        mediaType = try container.decode(FavoriteType.self, forKey: .mediaType)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(String.self, forKey: .date)
        description = try container.decode(String.self, forKey: .description)
        thumbnailLink = try container.decode(String.self, forKey: .thumbnailLink)
    }
    
    init(nasaId: String, assetLink: String, thumbnailLink: String, mediaType: FavoriteType, title: String, date: String, description: String) {
        self.nasaId = nasaId
        self.assetLink = assetLink
        self.thumbnailLink = thumbnailLink
        self.mediaType = mediaType
        self.title = title
        self.date = date
        self.description = description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(nasaId, forKey: .nasaId)
        try container.encode(assetLink, forKey: .assetLink)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(description, forKey: .description)
        try container.encode(thumbnailLink, forKey: .thumbnailLink)
    }
    
}

enum FavoriteType: String, Codable {
    case image = "image"
    case video = "video"
}
