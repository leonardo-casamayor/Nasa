//
//  NasaImageVideoLibrary.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import Foundation

struct NasaImageVideoLibrary: Decodable {
    var collection: Collection
}


struct Collection: Decodable {
    var items: [Item]
}

struct Item: Decodable {
    var data: [NasaData]
    var links: [Links]
    var href: String
    
    enum CodingKeys: CodingKey {
        case data, links, href
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decodeIfPresent([Links].self, forKey: .links) ?? [Links]()
        data = try container.decode([NasaData].self, forKey: .data)
        href = try container.decodeIfPresent(String.self, forKey: .href) ?? ""
    }
}

struct NasaData: Decodable {
    var nasaID: String
    var title: String
    var dateCreated: String
    var mediaType: MediaType
    var keywords: [String]
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case title, keywords, description
        case nasaID = "nasa_id"
        case mediaType = "media_type"
        case dateCreated = "date_created"
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nasaID = try container.decode(String.self, forKey: .nasaID)
        title = try container.decode(String.self, forKey: .title)
        dateCreated = try container.decode(String.self, forKey: .dateCreated)
        mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? [String]()
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
}

enum MediaType: Decodable, Equatable {
    case video, image
    case unknown(value: String)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "video": self = .video
            case "image": self = .image
            default:
                self = .unknown(value: status ?? "unknown")
        }
    }
}

struct Links: Decodable {
    var href: String
    
    enum CodingKeys: String, CodingKey {
        case href
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        href = try container.decodeIfPresent(String.self, forKey: .href) ?? ""
    }
}
